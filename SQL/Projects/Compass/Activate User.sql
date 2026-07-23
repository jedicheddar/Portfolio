USE COMPASS
GO

DECLARE @userTable TABLE (username VARCHAR(100))
INSERT INTO @userTable (username) VALUES ('')

UPDATE  [COMPASS].[dbo].[sysuser]
SET     [isActive] = 1
WHERE   [uid] IN (SELECT [username] FROM @userTable)  

SELECT  *
FROM    [COMPASS].[dbo].[sysuser]
WHERE   [uid] IN (SELECT [username] FROM @userTable)  

GO