DECLARE @fileNumber VARCHAR(100) = '',
        @formID VARCHAR(10) = '',
        @oldPolicy INT = 0,
        @newPolicy INT = 0

SELECT  *
FROM    batchform
WHERE   fileNumber = @fileNumber
AND     policyID = @oldPolicy
AND     formID = @formID

IF (@@ROWCOUNT = 1)
BEGIN
  UPDATE  batchform
  SET     policyID = @newPolicy
  WHERE   fileNumber = @fileNumber
  AND     policyID = @oldPolicy
  AND     formID = @formID
END

SELECT  *
FROM    batchform
WHERE   fileNumber = @fileNumber
AND     policyID = @oldPolicy
AND     formID = @formID

SELECT  *
FROM    policy
WHERE   policyID = @newPolicy

IF (@@ROWCOUNT = 1)
BEGIN
  UPDATE  policy
  SET     fileNumber = @fileNumber
  WHERE   policyID = @newPolicy
END

SELECT  *
FROM    policy
WHERE   policyID = @newPolicy