
CREATE PROCEDURE CallApi
AS
BEGIN
    DECLARE @Object INT;
    Declare @ResponseText as Varchar(8000);
    DECLARE @Status INT;

    -- Create the OLE object
    EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUTPUT ;

    -- Open the connection
    EXEC sp_OAMethod @Object, 'Open', NULL, 'GET', 'https://pokeapi.co/api/v2/berry/1', 'false';

    -- Send the request
    EXEC sp_OAMethod @Object, 'Send';

    -- Get the response status
    EXEC sp_OAMethod @Object, 'Status', @Status OUTPUT;

    -- Get the response text
    EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

    -- Clean up
    EXEC sp_OADestroy @Object;

    -- Return the response
    SELECT @Status AS Status, @ResponseText AS Response;
END;

DECLARE @Object INT;
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @Status INT;

-- Create the OLE object
EXEC sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUTPUT;

-- Open the connection
EXEC sp_OAMethod @Object, 'Open', NULL, 'GET', 'https://pokeapi.co/api/v2/berry/1', 'false';

-- Send the request
EXEC sp_OAMethod @Object, 'Send';

-- Get the response status
EXEC sp_OAMethod @Object, 'Status', @Status OUTPUT;

-- Get the response text
EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;

-- Clean up
EXEC sp_OADestroy @Object;

-- Return the response
SELECT @Status AS Status, @ResponseText AS Response;



Declare @jsonObject NVARCHAR(MAX);

SET @jsonObject = N'{"firmness"
:{"name":"soft","url":"https://pokeapi.co/api/v2/berry-firmness/2/"},
"flavors":[
{"flavor":{"name":"spicy","url":"https://pokeapi.co/api/v2/berry-flavor/1/"},"potency":10},
{"flavor":{"name":"dry","url":"https://pokeapi.co/api/v2/berry-flavor/2/"},"potency":0},
{"flavor":{"name":"sweet","url":"https://pokeapi.co/api/v2/berry-flavor/3/"},"potency":0},
{"flavor":{"name":"bitter","url":"https://pokeapi.co/api/v2/berry-flavor/4/"},"potency":0},
{"flavor":{"name":"sour","url":"https://pokeapi.co/api/v2/berry-flavor/5/"},"potency":0}],"growth_time":3,"id":1,"item":
{"name":"cheri-berry","url":"https://pokeapi.co/api/v2/item/126/"},"max_harvest":5,"name":"cheri","natural_gift_power":60,"natural_gift_type":
{"name":"fire","url":"https://pokeapi.co/api/v2/type/10/"},"size":20,"smoothness":25,"soil_dryness":15}'

SELECT 
    flavor_name,
    potency
FROM OPENJSON(@jsonObject, '$.flavors') 
WITH (
    flavor_name NVARCHAR(100) '$.flavor.name',
    potency INT '$.potency'
);

insert into flavor_berries(flavor.flavor_name, flavor.potency) 
SELECT 
    flavor_name,
    potency
FROM OPENJSON(@jsonObject, '$.flavors') 
WITH (
    flavor_name NVARCHAR(100) '$.flavor.name',
    potency INT '$.potency'
)as flavor;
commit;

select * From flavor_berries;
--create table flavor_berries(
--    flavor_name VARCHAR(1000),
--    potency Int
--);
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;


-- ================================================
-- SQL SERVER JSON + API + CRUD CHEAT SHEET (SSMS)
-- ================================================

-- ================================================
-- ============ 1. WORKING WITH JSON ==============
-- ================================================

-- 🟢 Parse JSON into rows
DECLARE @json NVARCHAR(MAX) = N'[{"id":1,"name":"Ash"},{"id":2,"name":"Misty"}]';
SELECT * FROM OPENJSON(@json);

-- 🟢 Parse JSON with schema
DECLARE @json2 NVARCHAR(MAX) = N'{
  "data": [
    { "id": 1, "name": "Ash" },
    { "id": 2, "name": "Misty" }
  ]
}';
SELECT id, name
FROM OPENJSON(@json2, '$.data')
WITH (
  id INT '$.id',
  name NVARCHAR(100) '$.name'
);

-- 🟢 Extract single value
DECLARE @simpleJson NVARCHAR(MAX) = N'{"name":"Pikachu","type":"Electric"}';
SELECT JSON_VALUE(@simpleJson, '$.name') AS Name;

-- 🟢 Extract nested array
DECLARE @nestedJson NVARCHAR(MAX) = N'{
  "user": {
    "name": "Ash",
    "pokemon": [
      {"name": "Pikachu"},
      {"name": "Charizard"}
    ]
  }
}';
SELECT name
FROM OPENJSON(@nestedJson, '$.user.pokemon')
WITH (
  name NVARCHAR(100) '$.name'
);

-- 🟢 Convert query to JSON
SELECT id, name
FROM (VALUES (1, 'Ash'), (2, 'Misty')) AS t(id, name)
FOR JSON PATH;

-- ================================================
-- ============ 2. DATABASE OPERATIONS ============
-- ================================================

-- 🔵 Create a sample table
CREATE TABLE Trainers (
  id INT PRIMARY KEY IDENTITY,
  name NVARCHAR(100),
  region NVARCHAR(100)
);

-- 🔵 Insert data
INSERT INTO Trainers (name, region)
VALUES ('Ash', 'Kanto'), ('Misty', 'Kanto');

-- 🔵 Select data
SELECT * FROM Trainers;

-- 🔵 Update data
UPDATE Trainers
SET region = 'Johto'
WHERE name = 'Ash';

-- 🔵 Delete data
DELETE FROM Trainers
WHERE name = 'Misty';

-- ================================================
-- ======= 3. CALLING EXTERNAL APIs (OLE) =========
-- ================================================

-- 🔴 Enable OLE Automation (one-time setup)
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;

-- 🔴 GET Request
DECLARE @Object INT, @ResponseText NVARCHAR(MAX);
DECLARE @Url NVARCHAR(1000) = 'https://pokeapi.co/api/v2/pokemon/pikachu';

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'GET', @Url, false;
EXEC sp_OAMethod @Object, 'send';
EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUTPUT;
EXEC sp_OADestroy @Object;

SELECT @ResponseText AS GetResponse;

-- 🔴 POST Request
DECLARE @PostUrl NVARCHAR(1000) = 'https://httpbin.org/post';
DECLARE @JsonBody NVARCHAR(MAX) = '{"name":"Pikachu","type":"Electric"}';

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'POST', @PostUrl, false;
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
EXEC sp_OAMethod @Object, 'send', NULL, @JsonBody;
EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUTPUT;
EXEC sp_OADestroy @Object;

SELECT @ResponseText AS PostResponse;

-- 🔴 PUT Request
DECLARE @PutUrl NVARCHAR(1000) = 'https://httpbin.org/put';
DECLARE @PutBody NVARCHAR(MAX) = '{"id":1,"region":"Sinnoh"}';

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'PUT', @PutUrl, false;
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json';
EXEC sp_OAMethod @Object, 'send', NULL, @PutBody;
EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUTPUT;
EXEC sp_OADestroy @Object;

SELECT @ResponseText AS PutResponse;

-- 🔴 DELETE Request
DECLARE @DeleteUrl NVARCHAR(1000) = 'https://httpbin.org/delete';

EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
EXEC sp_OAMethod @Object, 'open', NULL, 'DELETE', @DeleteUrl, false;
EXEC sp_OAMethod @Object, 'send';
EXEC sp_OAGetProperty @Object, 'responseText', @ResponseText OUTPUT;
EXEC sp_OADestroy @Object;

SELECT @ResponseText AS DeleteResponse;

-- ================================================
-- =========== 4. FUNCTION REFERENCE ==============
-- ================================================

-- JSON_VALUE()   => Extract single value
-- JSON_QUERY()   => Extract object or array
-- OPENJSON()     => Parse JSON into table rows
-- FOR JSON PATH  => Generate structured JSON
-- FOR JSON AUTO  => Auto-structure JSON
-- sp_OACreate    => Used to call APIs (POST, PUT, GET, DELETE)

