DECLARE @alertID INTEGER = 0,
        @agentID VARCHAR(30) = '',
        @code VARCHAR(30) = '',
        @delete BIT = 0

SELECT  [alertID],
        [agentID],
        (SELECT [name] FROM [agent] WHERE [agentID] = a.[agentID]) AS [name],
        [source],
        [processCode],
        (SELECT [description] FROM [syscode] WHERE [codeType] = 'Alert' AND [code] = a.[processCode]) AS [codeDesc],
        [score],
        [description],
        [dateCreated],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Alert' AND [objProperty] = 'Status' AND [objID] = a.[stat]) AS [status],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Alert' AND [objProperty] = 'Owner' AND [objID] = a.[owner]) AS [owner]
FROM    [dbo].[alert] a
WHERE   [alertID] = CASE WHEN @alertID = 0 THEN [alertID] ELSE @alertID END
AND     [agentID] = CASE WHEN @agentID = '' THEN [agentID] ELSE @agentID END
AND     [processCode] = CASE WHEN @code = '' THEN [processCode] ELSE @code END
ORDER BY [dateCreated] DESC

IF (@delete = 1)
  DELETE FROM [dbo].[alert] WHERE [alertID] = @alertID