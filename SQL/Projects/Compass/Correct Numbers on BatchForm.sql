CREATE TABLE #policyUpdate
(
  [policyID] INT,
  [netPremium] DECIMAL(18,2),
  [grossPremium] DECIMAL(18,2),
  [retentionPremium] DECIMAL(18,2),
  [liabilityAmount] DECIMAL(18,2)
)

CREATE TABLE #batchCorrection
(
  [batchID] INT,
  [policyID] INT,
  [currNetPremium] DECIMAL(18,2),
  [currGrossPremium] DECIMAL(18,2),
  [currRetentionPremium] DECIMAL(18,2),
  [currLiabilityAmount] DECIMAL(18,2),
  [deltaNetPremium] DECIMAL(18,2),
  [deltaGrossPremium] DECIMAL(18,2),
  [deltaRetentionPremium] DECIMAL(18,2),
  [deltaLiabilityAmount] DECIMAL(18,2)
)

DECLARE @batchID INTEGER = 0,
        @migrate BIT = 0

INSERT INTO #policyUpdate ([policyID],[netPremium],[grossPremium],[retentionPremium],[liabilityAmount]) VALUES (0,0,0,0,0)

DECLARE @netDelta DECIMAL(18,2) = 0,
        @grossDelta DECIMAL(18,2) = 0,
        @retentionDelta DECIMAL(18,2) = 0,
        @liabilityDelta DECIMAL(18,2) = 0,
        @count INT = 0

SELECT @count=[policyID] FROM #policyUpdate

IF (@count > 0)
BEGIN
  --Get the deltas
  INSERT INTO #batchCorrection ([batchID],[policyID],[currNetPremium],[currGrossPremium],[currRetentionPremium],[currLiabilityAmount],[deltaNetPremium],[deltaGrossPremium],[deltaRetentionPremium],[deltaLiabilityAmount])
  SELECT  @batchID,
          bf.[policyID],
          bf.[netPremium] AS [currNetPremium],
          bf.[grossPremium] AS [currGrossPremium],
          bf.[retentionPremium] AS [currRetentionPremium],
          bf.[liabilityAmount] AS [currLiabilityAmount],
          bf.[netPremium] - CASE WHEN pu.[netPremium] = 0 THEN bf.[netPremium] ELSE pu.[netPremium] END AS [deltaNetPremium],
          bf.[grossPremium] - CASE WHEN pu.[grossPremium] = 0 THEN bf.[grossPremium] ELSE pu.[grossPremium] END AS [deltaGrossPremium],
          bf.[retentionPremium] - CASE WHEN pu.[retentionPremium] = 0 THEN bf.[retentionPremium] ELSE pu.[retentionPremium] END AS [deltaRetentionPremium],
          bf.[liabilityAmount] - CASE WHEN pu.[liabilityAmount] = 0 THEN bf.[liabilityAmount] ELSE pu.[liabilityAmount] END AS [deltaLiabilityAmount]
  FROM    [dbo].[batchform] bf INNER JOIN
          #policyUpdate pu
  ON      bf.[batchID] = @batchID
  AND     bf.[policyID] = pu.[policyID]
  AND     bf.[formType] = 'P'

  --see what the difference sould look like
  SELECT  [batchID],
          [netPremiumProcessed] AS [currentNet],
          [netPremiumProcessed] - bc.[netDelta] AS [newNet],
          [grossPremiumProcessed] AS [currentGross],
          [grossPremiumProcessed] - bc.[grossDelta] AS [newGross],
          [retainedPremiumProcessed] AS [currentRetained],
          [retainedPremiumProcessed] - bc.[retentionDelta] AS [newRetained],
          [liabilityAmount] AS [currentLiability],
          [liabilityAmount] - bc.[liabilityDelta] AS [newLiability]
  FROM    [dbo].[batch] b CROSS JOIN
          (
          SELECT  SUM([deltaNetPremium]) AS [netDelta],
                  SUM([deltaGrossPremium]) AS [grossDelta],
                  SUM([deltaRetentionPremium]) AS [retentionDelta],
                  SUM([deltaLiabilityAmount]) AS [liabilityDelta]
          FROM    #batchCorrection
          ) bc
  WHERE   [batchID] = @batchID

  SELECT  bf.[batchID],
          bf.[policyID],
          bf.[netPremium] AS [currentNet],
          bf.[netPremium] - bc.[deltaNetPremium] AS [newNet],
          bf.[grossPremium] AS [currentGross],
          bf.[grossPremium] - bc.[deltaGrossPremium] AS [newGross],
          bf.[retentionPremium] AS [currentRetained],
          bf.[retentionPremium] - bc.[deltaRetentionPremium] AS [newRetained],
          bf.[liabilityAmount] AS [currentLiability],
          bf.[liabilityAmount] - bc.[deltaLiabilityAmount] AS [newLiability]
  FROM    [dbo].[batchform] bf INNER JOIN
          #batchCorrection bc
  ON      bf.[batchID] = bc.[batchID]
  AND     bf.[policyID] = bc.[policyID]
  AND     bf.[formType] = 'P'
  ORDER BY bf.[policyID]

  SELECT  p.[policyID],
          p.[netPremium] AS [currentNet],
          p.[netPremium] - bc.[deltaNetPremium] AS [newNet],
          p.[grossPremium] AS [currentGross],
          p.[grossPremium] - bc.[deltaGrossPremium] AS [newGross],
          p.[retentionPremium] AS [currentRetained],
          p.[retentionPremium] - bc.[deltaRetentionPremium] AS [newRetained],
          p.[liabilityAmount] AS [currentLiability],
          p.[liabilityAmount] - bc.[deltaLiabilityAmount] AS [newLiability]
  FROM    [dbo].[policy] p INNER JOIN
          #batchCorrection bc
  ON      p.[policyID] = bc.[policyID]
  ORDER BY p.[policyID]

  IF @migrate = 1
  BEGIN
    UPDATE  [dbo].[batch]
    SET     [netPremiumProcessed] = [netPremiumProcessed] - bc.[netDelta],
            [netPremiumDelta] = [netPremiumDelta] - bc.[netDelta],
            [netPremiumReported] = [netPremiumReported] - bc.[netDelta],
            [grossPremiumProcessed] = [grossPremiumProcessed] - bc.[grossDelta],
            [grossPremiumDelta] = [grossPremiumDelta] - bc.[grossDelta],
            [retainedPremiumProcessed] = [retainedPremiumProcessed] - bc.[retentionDelta],
            [retainedPremiumDelta] = [retainedPremiumDelta] - bc.[retentionDelta],
            [liabilityAmount] = [liabilityAmount] - bc.[liabilityDelta],
            [liabilityDelta] = b.[liabilityDelta] - bc.[liabilityDelta]
    FROM    [dbo].[batch] b CROSS JOIN
            (
            SELECT  SUM([deltaNetPremium]) AS [netDelta],
                    SUM([deltaGrossPremium]) AS [grossDelta],
                    SUM([deltaRetentionPremium]) AS [retentionDelta],
                    SUM([deltaLiabilityAmount]) AS [liabilityDelta]
            FROM    #batchCorrection
            ) bc
    WHERE   [batchID] = @batchID

    SELECT  [batchID],
            [netPremiumProcessed] AS [currentNet],
            [grossPremiumProcessed] AS [currentGross],
            [retainedPremiumProcessed] AS [currentRetained],
            [liabilityAmount] AS [currentLiability]
    FROM    [dbo].[batch]
    WHERE   [batchID] = @batchID

    UPDATE  [dbo].[batchform]
    SET     [netPremium] = [netPremium] - [deltaNetPremium],
            [netDelta] = [netDelta] - [deltaNetPremium],
            [grossPremium] = [grossPremium] - [deltaGrossPremium],
            [grossDelta] = [grossDelta] - [deltaGrossPremium],
            [retentionPremium] = [retentionPremium] - [deltaRetentionPremium],
            [retentionDelta] = [retentionDelta] - [deltaRetentionPremium],
            [liabilityAmount] = [liabilityAmount] - [deltaLiabilityAmount],
            [liabilityDelta] = [liabilityDelta] - [deltaLiabilityAmount]
    FROM    [dbo].[batchform] bf INNER JOIN
            #batchCorrection bc
    ON      bf.[batchID] = bc.[batchID]
    AND     bf.[policyID] = bc.[policyID]
    AND     bf.[formType] = 'P'

    SELECT  [batchID],
            [policyID],
            [netPremium] AS [currentNet],
            [grossPremium] AS [currentGross],
            [retentionPremium] AS [currentRetained],
            [liabilityAmount] AS [currentLiability]
    FROM    [dbo].[batchform]
    WHERE   [batchID] = @batchID
    AND     [policyID] IN (SELECT [policyID] FROM #batchCorrection)
    AND     [formType] = 'P'
    ORDER BY [policyID]

    UPDATE  [dbo].[policy]
    SET     [netPremium] = [netPremium] - [deltaNetPremium],
            [grossPremium] = [grossPremium] - [deltaGrossPremium],
            [retentionPremium] = [retentionPremium] - [deltaRetentionPremium],
            [liabilityAmount] = [liabilityAmount] - [deltaLiabilityAmount]
    FROM    [dbo].[policy] p INNER JOIN
            #batchCorrection bc
    ON      p.[policyID] = bc.[policyID]

    SELECT  [policyID],
            [netPremium] AS [currentNet],
            [grossPremium] AS [currentGross],
            [retentionPremium] AS [currentRetained],
            [liabilityAmount] AS [currentLiability]
    FROM    [dbo].[policy]
    WHERE   [policyID] IN (SELECT [policyID] FROM #batchCorrection)
    ORDER BY [policyID]
  END
END
ELSE
BEGIN
  SELECT  'BatchForm',
          b.[batchID],
          SUM(bf.[netDelta]) AS [netDelta],
          SUM(bf.[netPremium]) AS [netProcessed],
          SUM(bf.[grossDelta]) AS [grossDelta],
          SUM(bf.[grossPremium]) AS [grossProcessed],
          SUM(bf.[retentionDelta]) AS [retentionDelta],
          SUM(bf.[retentionPremium]) AS [retentionProcessed],
          SUM(bf.[liabilityDelta]) AS [liabilityDelta],
          SUM(bf.[liabilityAmount]) AS [liabilityAmount]
  FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
          [dbo].[batch] b
  ON      bf.[batchID] = b.[batchID]
  WHERE   b.[batchID] = @batchID
  GROUP BY b.[batchID]

  SELECT  'Before Update',
          b.[batchID],
          b.[netPremiumDelta],
          b.[netPremiumProcessed],
          b.[grossPremiumDelta],
          b.[grossPremiumProcessed],
          b.[retainedPremiumDelta],
          b.[retainedPremiumProcessed],
          b.[liabilityDelta],
          b.[liabilityAmount]
  FROM    [batch] b
  WHERE   b.[batchID] = @batchID

  IF (@migrate = 1)
  BEGIN
    UPDATE  [batch]
    SET     [netPremiumDelta] = ISNULL(bf.[netDelta],0),
            [netPremiumProcessed] = ISNULL(bf.[netProcessed],0),
            [grossPremiumDelta] = ISNULL(bf.[grossDelta],0),
            [grossPremiumProcessed] = ISNULL(bf.[grossProcessed],0),
            [retainedPremiumDelta] = ISNULL(bf.[retentionDelta],0),
            [retainedPremiumProcessed] = ISNULL(bf.[retentionProcessed],0),
            [liabilityDelta] = bf.[liabilityDelta],
            [liabilityAmount] = bf.[liabilityAmount]
    FROM    [batch] b INNER JOIN (
            SELECT  b.[batchID],
                    SUM(bf.[netDelta]) AS [netDelta],
                    SUM(bf.[netPremium]) AS [netProcessed],
                    SUM(bf.[grossDelta]) AS [grossDelta],
                    SUM(bf.[grossPremium]) AS [grossProcessed],
                    SUM(bf.[retentionDelta]) AS [retentionDelta],
                    SUM(bf.[retentionPremium]) AS [retentionProcessed],
                    SUM(bf.[liabilityDelta]) AS [liabilityDelta],
                    SUM(bf.[liabilityAmount]) AS [liabilityAmount]
            FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
                    [dbo].[batch] b
            ON      bf.[batchID] = b.[batchID]
            WHERE   b.[batchID] = @batchID
            GROUP BY b.[batchID]
            ) bf
    ON      bf.[batchID] = b.[batchID]

    SELECT  'After Update',
            b.[batchID],
            b.[netPremiumDelta],
            b.[netPremiumProcessed],
            b.[grossPremiumDelta],
            b.[grossPremiumProcessed],
            b.[retainedPremiumDelta],
            b.[retainedPremiumProcessed],
            b.[liabilityDelta],
            b.[liabilityAmount]
    FROM    [batch] b
    WHERE   b.[batchID] = @batchID
  END
END

DROP TABLE #policyUpdate
DROP TABLE #batchCorrection