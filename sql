
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
