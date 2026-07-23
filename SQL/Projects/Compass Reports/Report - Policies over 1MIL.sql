DECLARE @startDate DATETIME = '',
        @endDate DATETIME = ''

SELECT  p.[policyID] AS [Policy Number],
        p.[issuedLiabilityAmount] AS [Policy Amount],
        p.[fileNumber] AS [File Number],
        a.[agentID] AS [Agent ID],
        a.[name] AS [Agent Name]
FROM    [policy] p INNER JOIN
        [agent] a
ON      p.[agentID] = a.[agentID]
WHERE   p.[issuedLiabilityAmount] > 1000000
AND     p.[issueDate] BETWEEN @startDate AND @endDate
ORDER BY [issuedLiabilityAmount] DESC