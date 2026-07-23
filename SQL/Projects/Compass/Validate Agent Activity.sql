USE [COMPASS]

DECLARE @category VARCHAR(30) = 'I'

SELECT  aa.[agentID],
        a.[name],
        aa.[year],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Activity' AND [objProperty] = 'Category' AND [objID] = aa.[category]) AS [category],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Activity' AND [objProperty] = 'Type' AND [objID] = aa.[type]) AS [type],
        aa.[month1],
        aa.[month2],
        aa.[month3],
        aa.[month4],
        aa.[month5],
        aa.[month6],
        aa.[month7],
        aa.[month8],
        aa.[month9],
        aa.[month10],
        aa.[month11],
        aa.[month12]
FROM    [dbo].[agentactivity] aa INNER JOIN
        [dbo].[agent] a
ON      a.[agentID] = aa.[agentID]
WHERE   [category] = CASE WHEN @category = '' THEN [category] ELSE @category END
AND     [type] = 'A'
AND     [year] = YEAR(GETDATE())
ORDER BY a.[agentID]