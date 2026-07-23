DECLARE @stateID VARCHAR(30) = ''

SELECT  a.[agentID] AS [Agent ID],
        a.[name] AS [Name],
        a.[stateID] AS [State],
        ISNULL(CONVERT(VARCHAR, a.[activeDate], 101), 'N/A') AS [Active Date],
        ISNULL((SELECT [name] FROM [dbo].[sysuser] WHERE [uid] = a.[uid]), 'N/A') AS [Manager],
        a.[liabilityLimit] AS [Policy Limit],
        MAX(ISNULL(q.[coverageAmt], 0)) AS [E&O Coverage]
FROM    (
        SELECT  COALESCE(o.[orgID], a.[agentID]) AS [entityID],
                a.[agentID],
                a.[name],
                a.[stateID],
                am.[uid],
                a.[activeDate],
                a.[liabilityLimit]
        FROM    [agent] a LEFT OUTER JOIN
                [agentmanager] am
        ON      a.[agentID] = am.[agentID]
        AND     am.[isPrimary] = 1
        AND     am.[stat] = 'A' LEFT OUTER JOIN
                [orgrole] o
        ON      a.[agentID] = o.[sourceID]
        WHERE   a.[stateID] = @stateID
        AND     a.[stat] = 'A'
        ) a LEFT OUTER JOIN
        [qualification] q
ON      a.[entityID] = q.[entityID]
GROUP BY a.[agentID], a.[name], a.[stateID], a.[activeDate], a.[uid], a.[liabilityLimit]
ORDER BY a.[agentID]