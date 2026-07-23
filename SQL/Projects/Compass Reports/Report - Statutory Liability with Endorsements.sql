DECLARE @startPeriodID INTEGER = 202110,
        @endPeriodID INTEGER = 202110,
        @stateID VARCHAR(100) = 'ALL'

CREATE TABLE #stateTable (stateID VARCHAR(2))
INSERT INTO #stateTable ([stateID])
SELECT [field] FROM [dbo].[GetEntityFilter] ('State', @stateID)

CREATE TABLE #temp
( 
  [stateID] VARCHAR(20),
  [agentID] VARCHAR(20),
  [batchID] INTEGER,
  [policyID] INTEGER,
  [formType] VARCHAR(30),
  [formID] VARCHAR(100),
  [fileNumber] VARCHAR(100),
  [grossDelta] DECIMAL(18,2),
  [netDelta] DECIMAL(18,2),
  [liabilityDelta] DECIMAL(18,2)
)

INSERT INTO #temp ([stateID],[agentID],[batchID],[policyID],[formType],[formID],[fileNumber],[grossDelta],[netDelta],[liabilityDelta])
SELECT  b.[stateID],
        b.[agentID],
        b.[batchID],
        bf.[policyID] AS [policyID],
        bf.[formType],
        bf.[formID],
        bf.[fileNumber],
        bf.[grossDelta] AS [grossDelta],
        bf.[netDelta] AS [netDelta],
        bf.[liabilityDelta]
FROM    [dbo].[batch] b INNER JOIN
        [dbo].[batchform] bf
ON      bf.[batchID] = b.[batchID] INNER JOIN
        #stateTable stateTable
ON      b.[stateID] = stateTable.[stateID]
WHERE   b.[periodID] BETWEEN @startPeriodID AND @endPeriodID

UPDATE  #temp
SET     [formID] = CASE WHEN [formType] = 'E' THEN ISNULL((SELECT [formID] FROM #temp WHERE [batchID] = t.[batchID] AND [policyID] = t.[policyID] AND [fileNumber] = t.[fileNumber] AND [formType] = 'P'), 'None') ELSE [formID] END
FROM    #temp t

SELECT  [agentID],
        [name],
        [stateID],
        [batchID],
        [fileNumber],
        [grossPremium],
        [netPremium],
        [ownerNum],
        [lenderNum],
        [ownerLiability],
        [lenderLiability],
        CASE
          WHEN [lenderLiability] = 0 AND [ownerLiability] = 0 THEN 0
          WHEN [lenderLiability] > 0 and [ownerLiability] = 0 THEN [lenderLiability]
          WHEN [lenderLiability] = 0 and [ownerLiability] > 0 THEN [ownerLiability]
          WHEN [lenderLiability] > [ownerLiability] THEN [lenderLiability]
          WHEN [lenderLiability] <= [ownerLiability] THEN [ownerLiability]
          ELSE 0
        END AS [reservableLiability],
        CASE
          WHEN [lenderLiability] = 0 AND [ownerLiability] = 0 THEN 'None'
          WHEN [lenderLiability] > 0 and [ownerLiability] = 0 THEN 'Lender Only'
          WHEN [lenderLiability] = 0 and [ownerLiability] > 0 THEN 'Owner Only'
          WHEN [lenderLiability] > [ownerLiability] THEN 'Lender Greater'
          WHEN [lenderLiability] <= [ownerLiability] THEN 'Owner Greater'
          ELSE 'Unknown'
        END AS [grouped]
FROM    (
        SELECT  a.[agentID],
                a.[name],
                t.[stateID],
                t.[batchID],
                t.[fileNumber],
                SUM(t.[grossDelta]) AS [grossPremium],
                SUM(t.[netDelta]) AS [netPremium],
                SUM(CASE WHEN sf.[insuredType] = 'O' THEN t.[liabilityDelta] ELSE 0 END) AS [ownerLiability],
                SUM(CASE WHEN sf.[insuredType] = 'L' THEN t.[liabilityDelta] ELSE 0 END) AS [lenderLiability],
                SUM(CASE WHEN sf.[insuredType] = 'O' THEN 1 ELSE 0 END) AS [ownerNum],
                SUM(CASE WHEN sf.[insuredType] = 'L' THEN 1 ELSE 0 END) AS [lenderNum]
        FROM    #temp t LEFT OUTER JOIN
                [dbo].[stateform] sf
        ON      sf.[stateID] = t.[stateID]
        AND     sf.[formID] = t.[formID] INNER JOIN
                [dbo].[agent] a
        ON      t.[agentID] = a.[agentID]
        GROUP BY a.[agentID],
                 a.[name],
                 t.[stateID],
                 t.[batchID],
                 t.[fileNumber]
        ) a
ORDER BY [agentID],
         [fileNumber]

--SELECT * FROM #temp WHERE [agentID] = '437221'

--SELECT  a.[agentID],
--        SUM(t.[grossDelta]) AS [grossPremium],
--        SUM(t.[netDelta]) AS [netPremium],
--        SUM(CASE WHEN sf.[insuredType] = 'O' THEN t.[liabilityDelta] ELSE 0 END) AS [ownerLiability],
--        SUM(CASE WHEN sf.[insuredType] = 'L' THEN t.[liabilityDelta] ELSE 0 END) AS [lenderLiability],
--        SUM(CASE WHEN sf.[insuredType] = 'O' THEN 1 ELSE 0 END) AS [ownerNum],
--        SUM(CASE WHEN sf.[insuredType] = 'L' THEN 1 ELSE 0 END) AS [lenderNum]
--FROM    #temp t LEFT OUTER JOIN
--        [dbo].[stateform] sf
--ON      sf.[stateID] = t.[stateID]
--AND     sf.[formID] = t.[formID] INNER JOIN
--        [dbo].[agent] a
--ON      t.[agentID] = a.[agentID]
--GROUP BY a.[agentID]
--ORDER BY a.[agentID]

DROP TABLE #stateTable
DROP TABLE #temp