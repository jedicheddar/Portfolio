GO

DECLARE @startDate DATETIME = '2025-01-01',
        @endDate DATETIME = DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,GETDATE()),0))

CREATE TABLE #ratioTable
(
  [agentID] VARCHAR(20),
  [laePaidDelta] DECIMAL(18,2),
  [lossPaidDelta]  DECIMAL(18,2),
  [laeReserveDelta]  DECIMAL(18,2),
  [lossReserveDelta]  DECIMAL(18,2),
  [recoveriesDelta] DECIMAL(18,2),
  [pendingRecoveries] DECIMAL(18,2),
  [netPremium] DECIMAL(18,2)
)

CREATE TABLE #qarTable
(
  [agentID] VARCHAR(20),
  [auditType] VARCHAR(20),
  [auditor] VARCHAR(100),
  [stat] VARCHAR(100),
  [qarScore] INTEGER,
  [auditStartDate] DATETIME,
  [auditEndDate] DATETIME,
  [auditReviewDate] DATETIME,
  [errScore] INTEGER,
  [grade] INTEGER,
  [seq] INTEGER
)
  
-- Insert statements for procedure here
INSERT INTO #ratioTable ([agentID],[laePaidDelta],[lossPaidDelta],[laeReserveDelta],[lossReserveDelta],[recoveriesDelta],[pendingRecoveries],[netPremium])
EXEC [dbo].[spReportClaimsRatio] @startDate = @startDate, @endDate = @endDate

INSERT INTO #qarTable ([agentID],[auditType],[auditor],[stat],[qarScore],[auditStartDate],[auditEndDate],[auditReviewDate],[errScore],[grade],[seq])
SELECT  q.[agentID],
        q.[auditType],
        q.[uid],
        q.[stat],
        q.[score] AS [qarScore],
        q.[auditStartDate],
        q.[auditFinishDate] AS [auditEndDate],
        q.[auditReviewDate],
        s.[score] AS [errScore],
        q.[grade],
        ROW_NUMBER() OVER(PARTITION BY q.[agentID] ORDER BY q.[auditStartDate] DESC) AS [seq]
FROM    [dbo].[qar] q LEFT OUTER JOIN
        [dbo].[qarsection] s
ON      q.[qarID] = s.[qarID]
AND     s.[sectionID] = 6
WHERE   q.[auditType] IN ('Q','E')
AND     q.[score] > 0
AND     s.[score] > 0
AND     q.[auditStartDate] > @startDate

SELECT  a.[agentID] AS [Agent ID],
        (SELECT [description] FROM [dbo].[state] WHERE [stateID] = a.[stateID]) AS [State],
        a.[name] AS [Agent Name],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = a.[stat]) AS [Agent Status],
        a.[activeDate] AS [Agent Active Date],
        ISNULL(b.[numPolicies],0) AS [No. of Policies],
        ISNULL(b.[netPremium],0) AS [Net Premium],
        ISNULL(c.[count],0) AS [No. of Claims],
        ISNULL(r.[laePaidDelta] + r.[lossPaidDelta] - r.[recoveriesDelta],0) AS [Costs Incurred],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'QAR' AND [objAction] = 'Audit' AND [objProperty] = 'Status' AND [objID] = q1.[stat]) AS [Audit Status],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'QAR' AND [objAction] = 'Audit' AND [objProperty] = 'Type' AND [objID] = q1.[auditType]) AS [Audit Type],
        q1.[qarScore] AS [Points],
        q1.[grade] AS [Score %],
        q1.[auditReviewDate] AS [Preliminary Report Date],
        q1.[auditStartDate] AS [Audit Start Date],
        q1.[auditEndDate] AS [Audit End Date],
        (SELECT [name] FROM [dbo].[sysuser] WHERE [uid] = q1.[auditor]) AS [Auditor],
        q2.[auditEndDate] AS [Last Audit End Date],
        (SELECT [objValue] FROM [dbo].[sysprop] WHERE [appCode] = 'QAR' AND [objAction] = 'Audit' AND [objProperty] = 'Type' AND [objID] = q2.[auditType]) AS [Last Audit Type]
FROM    [dbo].[agent] a LEFT OUTER JOIN
        (
        SELECT  b.[agentID],
                SUM(CASE WHEN bf.[formType] = 'E' THEN 1 ELSE 0 END) AS [numForms],
                SUM(CASE WHEN bf.[formType] = 'P' THEN 1 ELSE 0 END) AS [numPolicies],
                SUM(bf.[netDelta]) AS [netPremium]
        FROM    [dbo].[batch] b INNER JOIN
                [dbo].[batchform] bf
        ON      b.[batchID] = bf.[batchID]
        GROUP BY b.[agentID]
        ) b
ON      b.[agentID] = a.[agentID] LEFT OUTER JOIN
        (
        SELECT  a.[agentID],
                COUNT(c.[claimID]) AS [count]
        FROM    [dbo].[agent] a INNER JOIN
                [dbo].[claim] c
        ON      a.[agentID] = c.[agentID]
        GROUP BY a.[agentID]
        ) c
ON      a.[agentID] = c.[agentID] LEFT OUTER JOIN
        #ratioTable r
ON      a.[agentID] = r.[agentID] LEFT OUTER JOIN
        #qarTable q1 
ON      a.[agentID] = q1.[agentID] LEFT OUTER JOIN
        #qarTable q2
ON      a.[agentID] = q2.[agentID]
AND     q2.[seq] = q1.[seq] - 1
WHERE   a.[stat] = 'A'
ORDER BY a.[agentID], q1.[auditStartDate]

DROP TABLE #qarTable
DROP TABLE #ratioTable