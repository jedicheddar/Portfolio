DECLARE @agentID VARCHAR(20) = '',
        @fileNumber VARCHAR(100) = '',
        @policyID INT = 2357785,
        @issueDate DATETIME = ''

SELECT  DISTINCT
        p.[policyID] AS [Policy ID],
        p.[stat] AS [Policy Stat],
        CASE sf.[insuredType]
          WHEN 'B' THEN 'Both'
          WHEN 'O' THEN 'Owners'
          WHEN 'L' THEN 'Lenders'
          ELSE 'Unknown'
        END AS [Policy Type],
        p.[issueDate] AS [Policy Issue Date],
        p.[effDate] AS [Effective Date],
        p.[liabilityAmount] AS [Liability Amount],
        p.[grossPremium] AS [Gross Premium],
        p.[netPremium] AS [Net Premium],
        b.[invoiceDate] AS [Processed Date],
        a.[agentID] AS [Agent ID],
        a.[name] AS [Agent Name],
        a.[stateID] AS [State ID],
        (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = a.[stat]) AS [Agent Status],
        p.[fileNumber] AS [File Number],
        p.[fileID] AS [File ID]
FROM    [dbo].[policy] p INNER JOIN
        (
        SELECT  a.[agentID],
                a.[stateID],
                a.[name],
                a.[stat],
                am.[uid] AS [manager]
        FROM    [dbo].[agent] a INNER JOIN
                [dbo].[agentmanager] am
        ON      a.[agentID] = am.[agentID]
        AND     am.[stat] = 'A'
        AND     am.[isPrimary] = 1
        WHERE   a.[agentID] = CASE WHEN @agentID = '' THEN a.[agentID] ELSE @agentID END
        ) a
ON      p.[agentID] = a.[agentID] LEFT OUTER JOIN
        [dbo].[stateform] sf
ON      p.[stateID] = sf.[stateID]
AND     p.[formID] = sf.[formID] RIGHT OUTER JOIN
        (
        SELECT  b.[agentID],
                bf.[policyID],
                b.[invoiceDate]
        FROM    [dbo].[batchform] bf INNER JOIN
                [dbo].[batch] b
        ON      bf.[batchID] = b.[batchID]
        ) b
ON      p.[policyID] = b.[policyID]
AND     p.[agentID] = b.[agentID]
WHERE   a.[agentID] = CASE WHEN @agentID = '' THEN a.[agentID] ELSE @agentID END
AND     p.[policyID] = CASE WHEN @policyID = 0 THEN p.[policyID] ELSE @policyID END
AND     p.[fileNumber] = CASE WHEN @fileNumber = 0 THEN p.[fileNumber] ELSE @fileNumber END
AND     p.[issueDate] >= CASE WHEN @issueDate IS NULL THEN p.[issueDate] ELSE @issueDate END
ORDER BY p.[policyID] DESC

IF (@@ROWCOUNT = 0)
  SELECT * FROM [policy] WHERE policyID = @policyID