DECLARE @policy table (id int)
--paste the list of policy numbers then use the regex to modfy them then run the SQL
--  Search for:   ^{.*}$
--  Replace with: INSERT INTO @policy (id) VALUES (\1)

--end of paste

SELECT  policyID, stat, agentID, liabilityAmount, grossPremium, netPremium, retentionPremium, trxID, trxDate
FROM    COMPASS.dbo.policy
WHERE   policyID in (SELECT id FROM @policy)
AND     stat = 'I'
AND     trxID like '%TXR%'

IF (@@ROWCOUNT > 0)
BEGIN
  BEGIN TRANSACTION
  --update
  UPDATE  COMPASS.dbo.policy
  SET     liabilityAmount = 0,
          grossPremium = 0,
          netPremium = 0,
          retentionPremium = 0
  WHERE   policyID in (SELECT id FROM @policy)
  AND     stat = 'I'
  AND     trxID like '%TXR%'

  --validation
  SELECT  policyID, stat, agentID, liabilityAmount, grossPremium, netPremium, retentionPremium, trxID, trxDate
  FROM    COMPASS.dbo.policy
  WHERE   policyID in (SELECT id FROM @policy)
  AND     stat = 'I'
  AND     trxID like '%TXR%'

  COMMIT TRANSACTION
END

