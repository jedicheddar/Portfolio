USE [COMPASS]

GO

DECLARE @policyCount INTEGER = 0,
        @tableCount INTEGER = 0

DECLARE @policyTable table (policyID int)
INSERT INTO @policyTable (policyID) VALUES (0)

SELECT  @tableCount = COUNT(*)
FROM    policy
WHERE   policyID in (SELECT [policyID] from @policyTable)
AND     policyID <> 0

SELECT  @policyCount = COUNT(*)
FROM    @policyTable

IF (@policyCount = @tableCount)
BEGIN
  SELECT  [policyID],
          [stat]
  FROM    policy
  WHERE   policyID IN (SELECT [policyID] from @policyTable)

  UPDATE  policy
  SET     stat = 'I'
  WHERE   policyID IN (SELECT [policyID] from @policyTable)
  AND     policyID <> 0

  SELECT  [policyID],
          [stat]
  FROM    policy
  WHERE   policyID IN (SELECT [policyID] from @policyTable)
END
ELSE
BEGIN
  SELECT  [policyID]
  FROM    @policyTable
  WHERE   [policyID] NOT IN (SELECT [policyID] from [policy])
END
GO