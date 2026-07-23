DECLARE @startDate DATETIME = '2018-07-01',
        @endDate DATETIME = '2021-06-30',
        @isGroup BIT = 0,
        @onlyActive BIT = 0,
        @payment DECIMAL(18,2) = 0

CREATE TABLE #balanceTable
(
[claimID] INT,
[refCategory] VARCHAR(10),
[asOfDate] DATETIME,
[pendingInvoiceAmount] DECIMAL(18,2),
[approvedInvoiceAmount] DECIMAL(18,2),
[completedInvoiceAmount] DECIMAL(18,2),
[pendingReserveAmount] DECIMAL(18,2),
[approvedReserveAmount] DECIMAL(18,2),
[reserveBalance] DECIMAL(18,2)
)

CREATE TABLE #deltaTable
(
[agentID] VARCHAR(20),
[claimID] INTEGER,
[laeCompletePayments] DECIMAL(18,2),
[lossCompletePayments] DECIMAL(18,2),
[laeReserveBalance] DECIMAL(18,2),
[lossReserveBalance] DECIMAL(18,2),
[laeCompletePaymentsAgentError] DECIMAL(18,2),
[lossCompletePaymentsAgentError] DECIMAL(18,2),
[laeReserveBalanceAgentError] DECIMAL(18,2),
[lossReserveBalanceAgentError] DECIMAL(18,2),
[pendingRecoveries] DECIMAL(18,2),
[recoveries] DECIMAL(18,2),
[netPremium] DECIMAL(18,2)
)

CREATE TABLE #ratioTable
(
[agentID] VARCHAR(20),
[claimID] INT,
[name] VARCHAR(100),
[stat] VARCHAR(20),
[stateID] VARCHAR(50),
[netPremium] DECIMAL(18,2),
[laeCompletePayments] DECIMAL(18,2),
[lossCompletePayments] DECIMAL(18,2),
[laeReserveBalance] DECIMAL(18,2),
[lossReserveBalance] DECIMAL(18,2),
[laeCompletePaymentsAgentError] DECIMAL(18,2),
[lossCompletePaymentsAgentError] DECIMAL(18,2),
[laeReserveBalanceAgentError] DECIMAL(18,2),
[lossReserveBalanceAgentError] DECIMAL(18,2),
[costsIncurred] DECIMAL(18,2),
[costsPaid] DECIMAL(18,2),
[costsIncurredAgentError] DECIMAL(18,2),
[costsPaidAgentError] DECIMAL(18,2),
[pendingRecoveries] DECIMAL(18,2),
[recoveries] DECIMAL(18,2)
)

CREATE TABLE #groupTable
(
[agentID] VARCHAR(20),
[groupNum] INTEGER,
[groupName] VARCHAR(200)
)

CREATE TABLE #excludeTable
(
[agentID] VARCHAR(20)
)

-- Insert into the groups
INSERT INTO #groupTable ([agentID], [groupNum], [groupName])
SELECT  [agentID],
        1,
        'Driggs'
FROM    [dbo].[agent]
WHERE   [agentID] = '287158'
OR      [agentID] = '031031'

INSERT INTO #groupTable ([agentID], [groupNum], [groupName])
SELECT  [agentID],
        2,
        'Flowers'
FROM    [dbo].[agent]
WHERE   [agentID] = '434001'
OR      [agentID] = '434005'
OR      [agentID] = '434003'

INSERT INTO #groupTable ([agentID], [groupNum], [groupName])
SELECT  [agentID],
        3,
        'Halo'
FROM    [dbo].[agent]
WHERE   [agentID] = '061026'
OR      [agentID] = '061030'
OR      [agentID] = '061031'
OR      [agentID] = '061029'
OR      [agentID] = '067351'

INSERT INTO #groupTable ([agentID], [groupNum], [groupName])
SELECT  [agentID],
        4,
        'Netco'
FROM    [dbo].[agent]
WHERE   [agentID] = '091000'
OR      [agentID] = '287156'
OR      [agentID] = '251000'
OR      [agentID] = '401025'
OR      [agentID] = '431060'
OR      [agentID] = '161000'
OR      [agentID] = '151000'
OR      [agentID] = '447212'
OR      [agentID] = '031030'

INSERT INTO #groupTable ([agentID], [groupNum], [groupName]) 
SELECT  [agentID],
        5,
        'Alpha Title'
FROM    [dbo].[agent]
WHERE   [agentID] = '167185'
OR      [agentID] = '257187'
OR      [agentID] = '167400'
OR      [agentID] = '257399'
OR      [agentID] = '167188'
OR      [agentID] = '257186'

-- Exclude agents

-- Decide the dates
IF (@startDate IS NULL)
  SET @startDate = '2005-01-01'

IF (@endDate IS NULL)
  SET @endDate = DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,GETDATE())+1,0))
    
-- The end date should be the last second of the day
SET @endDate = DATEADD(s,-1,DATEADD(d,1,@endDate))

-- Get the claim balances
INSERT INTO #balanceTable ([claimID],[refCategory],[asOfDate],[pendingInvoiceAmount],[approvedInvoiceAmount],[completedInvoiceAmount],[pendingReserveAmount],[approvedReserveAmount],[reserveBalance])
EXEC [dbo].[spReportClaimBalances] @asOfDate = @startDate

INSERT INTO #balanceTable ([claimID],[refCategory],[asOfDate],[pendingInvoiceAmount],[approvedInvoiceAmount],[completedInvoiceAmount],[pendingReserveAmount],[approvedReserveAmount],[reserveBalance])
EXEC [dbo].[spReportClaimBalances] @asOfDate = @endDate

-- Get the deltas
INSERT INTO #deltaTable ([agentID],[claimID],[laeCompletePayments],[lossCompletePayments],[laeReserveBalance],[lossReserveBalance],[laeCompletePaymentsAgentError],[lossCompletePaymentsAgentError],[laeReserveBalanceAgentError],[lossReserveBalanceAgentError],[pendingRecoveries],[recoveries],[netPremium])
SELECT  COALESCE(batch.[agentID],claim.[agentID]),
        ISNULL(claim.[claimID],0),
        ISNULL(claim.[laeCompletePayments],0),
        ISNULL(claim.[lossCompletePayments],0),
        ISNULL(claim.[laeReserveBalance],0),
        ISNULL(claim.[lossReserveBalance],0),
        ISNULL(claim.[laeCompletePaymentsAgentError],0),
        ISNULL(claim.[lossCompletePaymentsAgentError],0),
        ISNULL(claim.[laeReserveBalanceAgentError],0),
        ISNULL(claim.[lossReserveBalanceAgentError],0),
        ISNULL(claim.[pendingRecoveries],0),
        ISNULL(claim.[recoveries],0),
        batch.[netPremium]
FROM    (
        SELECT  [agentID],
                CONVERT(DECIMAL(18,2),ISNULL(SUM(batch.[netPremiumDelta]),0)) AS [netPremium]
        FROM    [dbo].[batch] INNER JOIN
                [dbo].[period]
        ON      batch.[periodID] = period.[periodID]
        WHERE   period.[startDate] >= @startDate
        AND     period.[endDate] <= @endDate
        AND     batch.[stat] = 'C'
        GROUP BY [agentID]
        ) batch FULL OUTER JOIN
        (
        SELECT  agent.[agentID],
                claim.[claimID],
                ISNULL(SUM(delta.[laeCompletePayments]),0) AS [laeCompletePayments],
                ISNULL(SUM(delta.[lossCompletePayments]),0) AS [lossCompletePayments],
                ISNULL(SUM(delta.[laeReserveBalance]),0) AS [laeReserveBalance],
                ISNULL(SUM(delta.[lossReserveBalance]),0) AS [lossReserveBalance],
                ISNULL(SUM(CASE WHEN claim.[agentError] = 'Y' THEN delta.[laeCompletePayments] ELSE 0 END),0) AS [laeCompletePaymentsAgentError],
                ISNULL(SUM(CASE WHEN claim.[agentError] = 'Y' THEN delta.[lossCompletePayments] ELSE 0 END),0) AS [lossCompletePaymentsAgentError],
                ISNULL(SUM(CASE WHEN claim.[agentError] = 'Y' THEN delta.[laeReserveBalance] ELSE 0 END),0) AS [laeReserveBalanceAgentError],
                ISNULL(SUM(CASE WHEN claim.[agentError] = 'Y' THEN delta.[lossReserveBalance] ELSE 0 END),0) AS [lossReserveBalanceAgentError],
                ISNULL(SUM(recoveries.[transAmount]),0) AS [recoveries],
                ISNULL(SUM(recoveries.[pendingAmount]),0) AS [pendingRecoveries]
        FROM    [dbo].[agent] agent INNER JOIN
                [dbo].[claim] claim
        ON      agent.[agentID] = claim.[agentID] LEFT OUTER JOIN
                (
                SELECT  [claimID],
                        SUM([EC]) AS [laeCompletePayments],
                        SUM([LC]) AS [lossCompletePayments],
                        SUM([ER]) AS [laeReserveBalance],
                        SUM([LR]) AS [lossReserveBalance]
                FROM    (
                        SELECT  curr.[claimID],
                                curr.[refCategory] + 'C' AS [complete],
                                curr.[refCategory] + 'R' AS [reserve],
                                curr.[completedInvoiceAmount] - prev.[completedInvoiceAmount] AS [completePayments],
                                curr.[reserveBalance] - prev.[reserveBalance] AS [reserveBalance]
                        FROM    #balanceTable curr INNER JOIN
                                #balanceTable prev
                        ON      prev.[refCategory] = curr.[refCategory]
                        AND     prev.[claimID] = curr.[claimID]
                        WHERE   prev.[asOfDate] = @startDate
                        AND     curr.[asOfDate] = @endDate
                        ) AS a
                        PIVOT
                        (
                        SUM([completePayments])
                        FOR [complete] IN (EC,LC)
                        ) AS p1
                        PIVOT
                        (
                        SUM([reserveBalance])
                        FOR [reserve] IN (ER,LR)
                        ) AS p2
                GROUP BY [claimID]
                ) delta
        ON      claim.[claimID] = delta.[claimID] LEFT OUTER JOIN
                (
                SELECT  CONVERT(INTEGER,inv.[refID]) AS [claimID],
                        SUM([requestedAmount]) - SUM([transAmount]) AS [pendingAmount],
                        SUM([transAmount]) AS [transAmount]
                FROM    [arinv] inv INNER JOIN
                        [artrx] trx
                ON      inv.[arinvID] = trx.[arinvID]
                WHERE   trx.[transDate] BETWEEN @startDate AND @endDate
                GROUP BY inv.[refID]
                ) recoveries
        ON      claim.[claimID] = recoveries.[claimID]
        WHERE   claim.[dateCreated] <= @endDate
        GROUP BY agent.[agentID], claim.[claimID]
        ) claim
ON      batch.[agentID] = claim.[agentID]

IF (@payment > 0)
BEGIN
  DELETE  d
  FROM    #deltaTable d INNER JOIN
         (
          SELECT  [agentID],
                  SUM([laeCompletePayments] + [lossCompletePayments]) AS [payment]
          FROM    #deltaTable
          GROUP BY [agentID]
          ) a
  ON      a.[agentID] = d.[agentID]
  WHERE   a.[payment] < @payment
END

IF (@isGroup = 1)
  DELETE FROM #deltaTable WHERE [agentID] NOT IN (SELECT [agentID] FROM #groupTable)

-- Exclude agents
DELETE FROM #deltaTable WHERE [agentID] IN (SELECT [agentID] FROM #excludeTable)

INSERT INTO #ratioTable ([agentID],[claimID],[name],[stat],[stateID],[netPremium],[laeCompletePayments],[lossCompletePayments],[laeReserveBalance],[lossReserveBalance],[laeCompletePaymentsAgentError],[lossCompletePaymentsAgentError],[laeReserveBalanceAgentError],[lossReserveBalanceAgentError],[pendingRecoveries],[recoveries],[costsIncurred],[costsPaid],[costsIncurredAgentError],[costsPaidAgentError])
SELECT  [agentID],
        [claimID],
        [name],
        [stat],
        [stateID],
        [netPremium],
        [laeCompletePayments],
        [lossCompletePayments],
        [laeReserveBalance],
        [lossReserveBalance],
        [laeCompletePaymentsAgentError],
        [lossCompletePaymentsAgentError],
        [laeReserveBalanceAgentError],
        [lossReserveBalanceAgentError],
        [pendingRecoveries],
        [recoveries],
        [costsIncurred],
        [costsPaid],
        [costsIncurredAgentError],
        [costsPaidAgentError]
FROM    (
        SELECT  a.[agentID],
                d.[claimID],
                a.[name],
                a.[stat],
                a.[stateID],
                d.[laeCompletePayments],
                d.[laeReserveBalance],
                d.[lossCompletePayments],
                d.[lossReserveBalance],
                d.[laeCompletePaymentsAgentError],
                d.[laeReserveBalanceAgentError],
                d.[lossCompletePaymentsAgentError],
                d.[lossReserveBalanceAgentError],
                d.[pendingRecoveries],
                d.[recoveries],
                d.[netPremium],
                d.[laeCompletePayments] + d.[laeReserveBalance] + d.[lossCompletePayments] + d.[lossReserveBalance] - d.[recoveries] AS [costsIncurred],
                d.[laeCompletePaymentsAgentError] + d.[laeReserveBalanceAgentError] + d.[lossCompletePaymentsAgentError] + d.[lossReserveBalanceAgentError] - d.[recoveries] AS [costsIncurredAgentError],
                d.[laeCompletePayments] + d.[lossCompletePayments] - d.[recoveries] AS [costsPaid],
                d.[laeCompletePaymentsAgentError] + d.[lossCompletePaymentsAgentError] - d.[recoveries] AS [costsPaidAgentError]
        FROM    [dbo].[agent] a INNER JOIN
                #deltaTable d
        ON      a.[agentID] = d.[agentID]
        WHERE   a.[stat] = CASE WHEN @onlyActive = 1 THEN 'A' ELSE a.[stat] END
        ) a

IF (@isGroup = 0)
BEGIN
  SELECT  '="' + [agentID] + '"' AS [Agent ID],
          [name] AS [Agent Name],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = [stat]) AS [Agent Status],
          [stateID] AS [State],
          [netPremium] AS [Net Premium],
          [laeCompletePayments] AS [LAE Paid],
          [laeReserveBalance] AS [LAE Reserve Change],
          [lossCompletePayments] AS [Loss Paid],
          [lossReserveBalance] AS [Loss Reserve Change],
          [recoveries] as [Recoveries Received],
          [pendingRecoveries] AS [Pending Recoveries],
          [costsIncurred] AS [Total Costs Incurred],
          [costsPaid] AS [Total Costs Paid],
          CASE WHEN [netPremium] = 0 THEN 0 ELSE [costsIncurred] / [netPremium] END AS [Cost Incurred Ratio],
          CASE WHEN [netPremium] = 0 THEN 0 ELSE [costsPaid] / [netPremium] END AS [Cost Paid Ratio]
  FROM    (
          SELECT  [agentID],
                  [name],
                  [stateID],
                  [stat],
                  ISNULL([netPremium],0) AS [netPremium],
                  SUM([laeCompletePayments]) AS [laeCompletePayments],
                  SUM([laeReserveBalance]) AS [laeReserveBalance],
                  SUM([lossCompletePayments]) AS [lossCompletePayments],
                  SUM([lossReserveBalance]) AS [lossReserveBalance],
                  SUM([recoveries]) as [recoveries],
                  SUM([pendingRecoveries]) AS [pendingRecoveries],
                  SUM([costsIncurred]) AS [costsIncurred],
                  SUM([costsPaid]) AS [costsPaid]
          FROM    #ratioTable
          GROUP BY [agentID], [name], [stateID], [stat], [netPremium]
          ) a
  ORDER BY [name]
  
  SELECT  '="' + [agentID] + '"' AS [Agent ID],
          [name] AS [Agent],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = [stat]) AS [Agent Status],
          [stateID] AS [State],
          [netPremium] AS [Net Premium],
          [laeCompletePayments] AS [LAE Paid],
          [laeReserveBalance] AS [LAE Reserve Change],
          [lossCompletePayments] AS [Loss Paid],
          [lossReserveBalance] AS [Loss Reserve Change],
          [recoveries] as [Recoveries Received],
          [pendingRecoveries] AS [Pending Recoveries],
          [costsIncurred] AS [Total Costs Incurred],
          [costsPaid] AS [Total Costs Paid],
          CASE WHEN [netPremium] = 0 THEN 0 ELSE [costsIncurred] / [netPremium] END AS [Cost Incurred Ratio],
          CASE WHEN [netPremium] = 0 THEN 0 ELSE [costsPaid] / [netPremium] END AS [Cost Paid Ratio]
  FROM    (
          SELECT  [agentID],
                  [name],
                  [stateID],
                  [stat],
                  ISNULL([netPremium],0) AS [netPremium],
                  SUM([laeCompletePaymentsAgentError]) AS [laeCompletePayments],
                  SUM([laeReserveBalanceAgentError]) AS [laeReserveBalance],
                  SUM([lossCompletePaymentsAgentError]) AS [lossCompletePayments],
                  SUM([lossReserveBalanceAgentError]) AS [lossReserveBalance],
                  SUM([recoveries]) as [recoveries],
                  SUM([pendingRecoveries]) AS [pendingRecoveries],
                  SUM([costsIncurredAgentError]) AS [costsIncurred],
                  SUM([costsPaidAgentError]) AS [costsPaid]
          FROM    #ratioTable
          GROUP BY [agentID], [name], [stateID], [stat], [netPremium]
          ) a
  ORDER BY [name]
          
  SELECT  '="' + c.[agentID] + '"' AS [Agent ID],
          c.[claimID] AS [Claim ID],
          CONVERT(VARCHAR,c.[dateCreated],101) AS [Date Opened],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'ClaimDescription' AND [objProperty] = 'Status' AND [objID] = c.[stat]) AS [Status],
          ISNULL((SELECT [name] FROM [sysuser] WHERE [uid] = c.[assignedTo]),'') AS [Administrator],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'ClaimDescription' AND [objProperty] = 'Stage' AND [objID] = c.[stage]) AS [Stage],
          a.[name] AS [Agent Name],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = a.[stat]) AS [Agent Status],
          ISNULL(claimcode.[ClaimCause],'') AS [Company Cause],
          ISNULL(claimcode.[ClaimDescription],'') AS [Company Description],
          CASE WHEN note.[lastNote] IS NULL THEN '' ELSE CONVERT(VARCHAR,note.[lastNote],101) END AS [Activity],
          dt.[laeCompletePayments] AS [LAE Paid],
          dt.[lossCompletePayments] AS [Loss Paid],
          dt.[laeReserveBalance] AS [LAE Reserve Change],
          dt.[lossReserveBalance] AS [Loss Reserve Change],
          dt.[laeCompletePaymentsAgentError] AS [LAE Paid Agent Error],
          dt.[lossCompletePaymentsAgentError] AS [Loss Paid Agent Error],
          dt.[laeReserveBalanceAgentError] AS [LAE Reserve Change Agent Error],
          dt.[lossReserveBalanceAgentError] AS [Loss Reserve Change Agent Error],
          dt.[recoveries] AS [Recoveries],
          dt.[pendingRecoveries] AS [Pending Recoveries]
  FROM    [dbo].[claim] c INNER JOIN
          [dbo].[agent] a
  ON      c.[agentID] = a.[agentID] INNER JOIN
          (
          SELECT  [claimID],
                  [laeCompletePayments],
                  [lossCompletePayments],
                  [laeReserveBalance],
                  [lossReserveBalance],
                  [laeCompletePaymentsAgentError],
                  [lossCompletePaymentsAgentError],
                  [laeReserveBalanceAgentError],
                  [lossReserveBalanceAgentError],
                  [pendingRecoveries],
                  [recoveries]
          FROM    #ratioTable
          ) dt
  ON      c.[claimID] = dt.[claimID] LEFT OUTER JOIN
          (
          SELECT  cc2.[claimID],
                  SUBSTRING(
                  (
                    SELECT  ', ' + sc.[description] AS [text()]
                    FROM    [syscode] sc INNER JOIN
                            [claimcode] cc
                    ON      cc.[code] = sc.[code]
                    AND     cc.[codeType] = sc.[codeType]
                    WHERE   cc.[claimID] = cc2.[claimID]
                    AND     sc.[codeType] = 'ClaimDescription'
                    ORDER BY cc.[claimID]
                    FOR XML PATH('')
                  ), 3, 1000) AS [ClaimDescription],
                  SUBSTRING(
                  (
                    SELECT  ', ' + sc.[description] AS [text()]
                    FROM    [syscode] sc INNER JOIN
                            [claimcode] cc
                    ON      cc.[code] = sc.[code]
                    AND     cc.[codeType] = sc.[codeType]
                    WHERE   cc.[claimID] = cc2.[claimID]
                    AND     sc.[codeType] = 'ClaimCause'
                    ORDER BY cc.[claimID]
                    FOR XML PATH('')
                  ), 3, 1000) AS [ClaimCause]
          FROM    [claimcode] cc2
          GROUP BY cc2.[claimID]
          ) claimcode 
  ON      c.[claimID] = claimcode.[claimID] LEFT OUTER JOIN
          (
          SELECT  [claimID],
                  MAX([noteDate]) AS [lastNote],
                  COUNT([seq]) AS [noteCnt]
          FROM    [dbo].[claimnote]
          GROUP BY [claimID]
          ) note
  ON      c.[claimID] = note.[claimID]
  ORDER BY a.[agentID]
END
ELSE
BEGIN
  SELECT  [groupNum] AS [Group #],
          [groupName] AS [Group Name],
          SUM([netPremium]) AS [Net Premium],
          SUM([laeCompletePayments]) AS [LAE Paid],
          SUM([laeReserveBalance]) AS [LAE Reserve Change],
          SUM([lossCompletePayments]) AS [Loss Paid],
          SUM([lossReserveBalance]) AS [Loss Reserve Change],
          SUM([recoveries]) as [Recoveries Received],
          SUM([pendingRecoveries]) AS [Pending Recoveries],
          SUM([costsIncurred]) AS [Total Costs Incurred],
          SUM([costsPaid]) AS [Total Costs Paid],
          SUM([costsIncurred]) / SUM([netPremium]) AS [Cost Incurred Ratio],
          SUM([costsPaid]) / SUM([netPremium]) AS [Cost Paid Ratio]
  FROM    (
          SELECT  [agentID],
                  [name],
                  [stateID],
                  [netPremium],
                  SUM([laeCompletePayments]) AS [laeCompletePayments],
                  SUM([laeReserveBalance]) AS [laeReserveBalance],
                  SUM([lossCompletePayments]) AS [lossCompletePayments],
                  SUM([lossReserveBalance]) AS [lossReserveBalance],
                  SUM([recoveries]) as [recoveries],
                  SUM([pendingRecoveries]) AS [pendingRecoveries],
                  SUM([costsIncurred]) AS [costsIncurred],
                  SUM([costsPaid]) AS [costsPaid]
          FROM    #ratioTable
          GROUP BY [agentID], [name], [stateID], [netPremium]
          ) a INNER JOIN
          #groupTable g
  ON      a.[agentID] = g.[agentID]
  GROUP BY [groupNum], [groupName]
  ORDER BY [groupNum], [groupName]
  
  SELECT  [groupNum] AS [Group #],
          [groupName] AS [Group Name],
          SUM([netPremium]) AS [Net Premium],
          SUM([laeCompletePayments]) AS [LAE Paid],
          SUM([laeReserveBalance]) AS [LAE Reserve Change],
          SUM([lossCompletePayments]) AS [Loss Paid],
          SUM([lossReserveBalance]) AS [Loss Reserve Change],
          SUM([recoveries]) AS [Recoveries Received],
          SUM([pendingRecoveries]) AS [Pending Recoveries],
          SUM([costsIncurred]) AS [Total Costs Incurred],
          SUM([costsPaid]) AS [Total Costs Paid],
          SUM([costsIncurred]) / SUM([netPremium]) AS [Cost Incurred Ratio],
          SUM([costsPaid]) / SUM([netPremium]) AS [Cost Paid Ratio]
  FROM    (
          SELECT  [agentID],
                  [name],
                  [stateID],
                  [netPremium],
                  SUM([laeCompletePaymentsAgentError]) AS [laeCompletePayments],
                  SUM([laeReserveBalanceAgentError]) AS [laeReserveBalance],
                  SUM([lossCompletePaymentsAgentError]) AS [lossCompletePayments],
                  SUM([lossReserveBalanceAgentError]) AS [lossReserveBalance],
                  SUM([recoveries]) as [recoveries],
                  SUM([pendingRecoveries]) AS [pendingRecoveries],
                  SUM([costsIncurredAgentError]) AS [costsIncurred],
                  SUM([costsPaidAgentError]) AS [costsPaid]
          FROM    #ratioTable
          GROUP BY [agentID], [name], [stateID], [netPremium]
          ) a INNER JOIN
          #groupTable g
  ON      a.[agentID] = g.[agentID]
  GROUP BY [groupNum], [groupName]
  ORDER BY [groupNum], [groupName]
          
  SELECT  g.[groupNum] AS [Group #],
          g.[groupName] AS [Group Name],
          '="' + c.[agentID] + '"' AS [Agent ID],
          c.[claimID] AS [Claim ID],
          CONVERT(VARCHAR,c.[dateCreated],101) AS [Date Opened],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'ClaimDescription' AND [objProperty] = 'Status' AND [objID] = c.[stat]) AS [Status],
          ISNULL((SELECT [name] FROM [sysuser] WHERE [uid] = c.[assignedTo]),'') AS [Administrator],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'ClaimDescription' AND [objProperty] = 'Stage' AND [objID] = c.[stage]) AS [Stage],
          a.[name] AS [Agent Name],
          (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Agent' AND [objProperty] = 'Status' AND [objID] = a.[stat]) AS [Agent Status],
          ISNULL(claimcode.[ClaimCause],'') AS [Company Cause],
          ISNULL(claimcode.[ClaimDescription],'') AS [Company Description],
          CASE WHEN note.[lastNote] IS NULL THEN '' ELSE CONVERT(VARCHAR,note.[lastNote],101) END AS [Activity],
          dt.[laeCompletePayments] AS [LAE Paid],
          dt.[lossCompletePayments] AS [Loss Paid],
          dt.[laeReserveBalance] AS [LAE Reserve Change],
          dt.[lossReserveBalance] AS [Loss Reserve Change],
          dt.[laeCompletePaymentsAgentError] AS [LAE Paid Agent Error],
          dt.[lossCompletePaymentsAgentError] AS [Loss Paid Agent Error],
          dt.[laeReserveBalanceAgentError] AS [LAE Reserve Change Agent Error],
          dt.[lossReserveBalanceAgentError] AS [Loss Reserve Change Agent Error],
          dt.[recoveries] AS [Recoveries],
          dt.[pendingRecoveries] AS [Pending Recoveries]
  FROM    [dbo].[claim] c INNER JOIN
          [dbo].[agent] a
  ON      c.[agentID] = a.[agentID] INNER JOIN
          (
          SELECT  [claimID],
                  [laeCompletePayments],
                  [lossCompletePayments],
                  [laeReserveBalance],
                  [lossReserveBalance],
                  [laeCompletePaymentsAgentError],
                  [lossCompletePaymentsAgentError],
                  [laeReserveBalanceAgentError],
                  [lossReserveBalanceAgentError],
                  [pendingRecoveries],
                  [recoveries]
          FROM    #ratioTable
          ) dt
  ON      c.[claimID] = dt.[claimID] LEFT OUTER JOIN
          (
          SELECT  cc2.[claimID],
                  SUBSTRING(
                  (
                    SELECT  ', ' + sc.[description] AS [text()]
                    FROM    [syscode] sc INNER JOIN
                            [claimcode] cc
                    ON      cc.[code] = sc.[code]
                    AND     cc.[codeType] = sc.[codeType]
                    WHERE   cc.[claimID] = cc2.[claimID]
                    AND     sc.[codeType] = 'ClaimDescription'
                    ORDER BY cc.[claimID]
                    FOR XML PATH('')
                  ), 3, 1000) AS [ClaimDescription],
                  SUBSTRING(
                  (
                    SELECT  ', ' + sc.[description] AS [text()]
                    FROM    [syscode] sc INNER JOIN
                            [claimcode] cc
                    ON      cc.[code] = sc.[code]
                    AND     cc.[codeType] = sc.[codeType]
                    WHERE   cc.[claimID] = cc2.[claimID]
                    AND     sc.[codeType] = 'ClaimCause'
                    ORDER BY cc.[claimID]
                    FOR XML PATH('')
                  ), 3, 1000) AS [ClaimCause]
          FROM    [claimcode] cc2
          GROUP BY cc2.[claimID]
          ) claimcode
  ON      c.[claimID] = claimcode.[claimID] LEFT OUTER JOIN
          (
          SELECT  [claimID],
                  MAX([noteDate]) AS [lastNote],
                  COUNT([seq]) AS [noteCnt]
          FROM    [dbo].[claimnote]
          GROUP BY [claimID]
          ) note
  ON      c.[claimID] = note.[claimID] INNER JOIN
          #groupTable g
  ON      c.[agentID] = g.[agentID]
  ORDER BY c.[dateCreated]
END

DROP TABLE #deltaTable
DROP TABLE #balanceTable
DROP TABLE #ratioTable
DROP TABLE #groupTable
DROP TABLE #excludeTable