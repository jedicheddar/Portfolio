/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @policyID INT = 0,
        @migrate BIT = 0

IF @policyID = 0
  RETURN

SELECT  [batchID],
        [policyID],
        [netPremium],
        [grossPremium],
        [retentionPremium],
        [liabilityAmount]
INTO    #policyUpdate
FROM    [batchform]
WHERE   [policyID] = @policyID

SELECT  'Batch',
        b.[batchID],
        b.[netPremiumDelta] AS [currentNet],
        pu.[netPremium] AS [newNet],
        b.[grossPremiumDelta] AS [currentGross],
        pu.[grossPremium] AS [newGross],
        b.[retainedPremiumDelta] AS [currentRetained],
        pu.[retentionPremium] AS [newRetained],
        b.[liabilityDelta] AS [currentLiability],
        pu.[liabilityAmount] AS [newLiability]
FROM    [dbo].[batch] b INNER JOIN
        #policyUpdate pu
ON      b.[batchID] = pu.[batchID]

SELECT  'BatchForm',
        bf.[batchID],
        bf.[policyID],
        bf.[netDelta] AS [currentNet],
        pu.[netPremium] AS [newNet],
        bf.[grossDelta] AS [currentGross],
        pu.[grossPremium] AS [newGross],
        bf.[retentionDelta] AS [currentRetained],
        pu.[retentionPremium] AS [newRetained],
        bf.[liabilityDelta] AS [currentLiability],
        pu.[liabilityAmount] AS [newLiability]
FROM    [dbo].[batchform] bf INNER JOIN
        #policyUpdate pu
ON      bf.[batchID] = pu.[batchID]
AND     bf.[policyID] = pu.[policyID]

SELECT  'Policy',
        p.[policyID],
        p.[netPremium] AS [currentNet],
        pu.[netPremium] AS [newNet],
        p.[grossPremium] AS [currentGross],
        pu.[grossPremium] AS [newGross],
        p.[retentionPremium] AS [currentRetained],
        pu.[retentionPremium] AS [newRetained],
        p.[liabilityAmount] AS [currentLiability],
        pu.[liabilityAmount] AS [newLiability]
FROM    [dbo].[policy] p INNER JOIN
        #policyUpdate pu
ON      p.[policyID] = pu.[policyID]

IF @migrate = 1
BEGIN
  UPDATE b
  SET   b.[netPremiumDelta] = pu.[netPremium],
        b.[grossPremiumDelta] = pu.[grossPremium],
        b.[retainedPremiumDelta] = pu.[retentionPremium],
        b.[liabilityDelta] = pu.[liabilityAmount]
  FROM  [batch] b INNER JOIN
        #policyUpdate pu
  ON    b.[batchID] = pu.[batchID]

  UPDATE bf
  SET   bf.[netDelta] = pu.[netPremium],
        bf.[grossDelta] = pu.[grossPremium],
        bf.[retentionDelta] = pu.[retentionPremium],
        bf.[liabilityDelta] = pu.[liabilityAmount]
  FROM  [batchform] bf INNER JOIN
        #policyUpdate pu
  ON    bf.[batchID] = pu.[batchID]
  AND   bf.[policyID] = pu.[policyID]
  
  UPDATE p
  SET   p.[netPremium] = pu.[netPremium],
        p.[grossPremium] = pu.[grossPremium],
        p.[retentionPremium] = pu.[retentionPremium],
        p.[liabilityAmount] = pu.[liabilityAmount]
  FROM  [policy] p INNER JOIN
        #policyUpdate pu
  ON    p.[policyID] = pu.[policyID]
END

DROP TABLE #policyUpdate