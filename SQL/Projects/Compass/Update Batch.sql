USE [COMPASS]

DECLARE @batch INT = 0,
        @agent VARCHAR(10) = '',
        @fileNumber VARCHAR(50) = '',
        @state VARCHAR(2) = '',
        @policyID INT = 0,
        @isComplete BIT = 0,
        @formID VARCHAR(10) = ''

DECLARE @liabilityDiff DECIMAL(18,2) = 0 --

SELECT  DISTINCT
        b.[batchID],
        b.[agentID],
        b.[periodYear],
        b.[periodMonth],
        bf.[formID],
        sf.[description],
        bf.[policyID],
        bf.[fileNumber],
        bf.[netDelta],
        bf.[grossDelta],
        bf.[liabilityAmount],
        bf.[liabilityDelta],
        b.[liabilityAmount],
        b.[liabilityDelta] 
FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
        [dbo].[batch] b
ON      bf.[batchID] = b.[batchID] INNER JOIN
        [dbo].[stateform] sf
ON      b.[stateID] = sf.[stateID]
AND     bf.[formID] = sf.[formID]
WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
AND     b.[batchID] = CASE WHEN @batch = 0 THEN b.[batchID] ELSE @batch END
AND     b.[stateID] = CASE WHEN @state = '' THEN b.[stateID] ELSE @state END
AND     bf.[policyID] = CASE WHEN @policyID = 0 THEN bf.[policyID] ELSE @policyID END
AND     b.[stat] LIKE CASE WHEN @isComplete = 1 then 'C' ELSE '%%' END
AND     bf.[fileNumber] = CASE WHEN @fileNumber = '' THEN bf.[fileNumber] ELSE @fileNumber END
AND     bf.[formID] = CASE WHEN @formID = '' THEN bf.[formID] ELSE @formID END
ORDER BY [policyID]

IF (@liabilityDiff > 0)
BEGIN
  --update batch
  UPDATE  [dbo].[batch]
  SET     [liabilityAmount] = b.[liabilityAmount] - @liabilityDiff
         ,[liabilityDelta] = b.[liabilityDelta] - @liabilityDiff
  FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
          [dbo].[batch] b
  ON      bf.[batchID] = b.[batchID]
  WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
  AND     b.[batchID] = CASE WHEN @batch = 0 THEN b.[batchID] ELSE @batch END
  AND     b.[stateID] = CASE WHEN @state = '' THEN b.[stateID] ELSE @state END
  AND     bf.[policyID] = CASE WHEN @policyID = 0 THEN bf.[policyID] ELSE @policyID END
  AND     b.[stat] LIKE CASE WHEN @isComplete = 1 then 'C' ELSE '%%' END
  AND     bf.[fileNumber] = CASE WHEN @fileNumber = '' THEN bf.[fileNumber] ELSE @fileNumber END
  AND     bf.[formID] = CASE WHEN @formID = '' THEN bf.[formID] ELSE @formID END

  --update batchform
  UPDATE  [dbo].[batchform]
  SET     [liabilityAmount] = bf.[liabilityAmount] - @liabilityDiff
         ,[liabilityDelta] = bf.[liabilityDelta] - @liabilityDiff
  FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
          [dbo].[batch] b
  ON      bf.[batchID] = b.[batchID]
  WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
  AND     b.[batchID] = CASE WHEN @batch = 0 THEN b.[batchID] ELSE @batch END
  AND     b.[stateID] = CASE WHEN @state = '' THEN b.[stateID] ELSE @state END
  AND     bf.[policyID] = CASE WHEN @policyID = 0 THEN bf.[policyID] ELSE @policyID END
  AND     b.[stat] LIKE CASE WHEN @isComplete = 1 then 'C' ELSE '%%' END
  AND     bf.[fileNumber] = CASE WHEN @fileNumber = '' THEN bf.[fileNumber] ELSE @fileNumber END
  AND     bf.[formID] = CASE WHEN @formID = '' THEN bf.[formID] ELSE @formID END

  --validate
  SELECT  DISTINCT
          b.[batchID],
          b.[agentID],
          b.[periodYear],
          b.[periodMonth],
          bf.[formID],
          sf.[description],
          bf.[policyID],
          bf.[fileNumber],
          bf.[netDelta],
          bf.[grossDelta],
          bf.[liabilityAmount],
          bf.[liabilityDelta],
          b.[liabilityAmount],
          b.[liabilityDelta] 
  FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
          [dbo].[batch] b
  ON      bf.[batchID] = b.[batchID] INNER JOIN
          [dbo].[stateform] sf
  ON      b.[stateID] = sf.[stateID]
  AND     bf.[formID] = sf.[formID]
  WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
  AND     b.[batchID] = CASE WHEN @batch = 0 THEN b.[batchID] ELSE @batch END
  AND     b.[stateID] = CASE WHEN @state = '' THEN b.[stateID] ELSE @state END
  AND     bf.[policyID] = CASE WHEN @policyID = 0 THEN bf.[policyID] ELSE @policyID END
  AND     b.[stat] LIKE CASE WHEN @isComplete = 1 then 'C' ELSE '%%' END
  AND     bf.[fileNumber] = CASE WHEN @fileNumber = '' THEN bf.[fileNumber] ELSE @fileNumber END
  AND     bf.[formID] = CASE WHEN @formID = '' THEN bf.[formID] ELSE @formID END
  ORDER BY [policyID]
END