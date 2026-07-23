DECLARE @name VARCHAR(100) = ''

SELECT  [agentID],[name]
FROM    [dbo].[agent]
WHERE   [name] LIKE '%' + @name + '%'