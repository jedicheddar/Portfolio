DECLARE @stateID VARCHAR(30) = '',
        @manager VARCHAR(50) = '',
        @agentID VARCHAR(30) = ''

SELECT  a.[agentID],
        a.[stateID],
        a.[name],
        a.[stat],
        a.[corporationID] AS [company],
        a.[swVendor],
        --(SELECT [description] FROM [syscode] WHERE [code] = a.[swVendor]) AS [software],
        am.[uid] AS [manager],
        am.[isPrimary]
FROM    [dbo].[agent] a INNER JOIN
        [dbo].[agentmanager] am
ON      a.[agentID] = am.[agentID]
AND     am.[stat] = 'A'
WHERE   a.[stateID] = CASE WHEN @stateID = '' THEN a.[stateID] ELSE @stateID END
AND     am.[uid] = CASE WHEN @manager = '' THEN am.[uid] ELSE @manager END
AND     a.[agentID] = CASE WHEN @agentID = '' THEN a.[agentID] ELSE @agentID END
ORDER BY am.[isPrimary] DESC,a.[agentID]