USE COMPASS

IF OBJECT_ID('tempdb.dbo.##agentLimit') IS NOT NULL
BEGIN
  DROP TABLE ##agentLimit
END

CREATE TABLE ##agentLimit (
  agentID VARCHAR(20),
  name VARCHAR(200),
  createdDate DATETIME,
  policyIssueDate DATETIME,
  policyIssuedEffDate DATETIME,
  fileNumber VARCHAR(50),
  maxCoverage DECIMAL(17,2),
  liability DECIMAL(17,2),
  policyID INT
)

INSERT INTO ##agentLimit (agentID,name,createdDate,policyIssueDate,policyIssuedEffDate,fileNumber,maxCoverage,liability,policyID)
SELECT  DISTINCT
        a.[agentID],
        a.[name],
        bf.[createdDate],
        p.[issueDate],
        p.[issuedEffDate],
        p.[fileNumber],
        a.[maxCoverage],
        bf.[liabilityAmount],
        p.[policyID]
FROM    [dbo].[agent] a
        inner join
        [dbo].[batch] b
        on a.[agentID] = b.[agentID]
        inner join
        [dbo].[batchform] bf
        on b.[batchID] = bf.[batchID]
        inner join
        [dbo].[policy] p
        on bf.[policyID] = p.[policyID]
WHERE   bf.[liabilityAmount] > a.[maxCoverage] 
AND     bf.[formType] = 'P'
AND     a.[maxCoverage] > 0
AND     a.[stat] = 'A'