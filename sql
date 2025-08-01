
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
