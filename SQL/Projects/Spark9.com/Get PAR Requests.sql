USE [alliant]

DECLARE @year INT = 2016,
        @delete BIT = 0,
        @count INT = NULL

SELECT @count = OBJECT_ID('tempdb.dbo.##agentLimit')
IF @delete = 1 AND @count IS NOT NULL
BEGIN
  DROP TABLE ##agentLimit
END

IF OBJECT_ID('tempdb.dbo.##agentLimit') IS NULL
BEGIN
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
END

DECLARE @parTable TABLE (parID INT,agentID VARCHAR(20),fileNumber VARCHAR(50),amount DECIMAL(17,2),approvedID INT,parDate DATETIME,approveDate DATETIME,UserID VARCHAR(200))
INSERT INTO @parTable (parID,agentID,fileNumber,amount,approvedID,parDate,approveDate,UserID)
SELECT  DISTINCT
        p.[FormID],
        a.[cintid],
        p.[GFileNums],
        CASE 
          WHEN p.[InsOwnerAmt] IS NOT NULL THEN p.[InsOwnerAmt]
          WHEN p.[InsMortgAmt] IS NOT NULL THEN p.[InsMortgAmt]
          ELSE 0
        END,
        f.[StatusID],
        p.[EntryTime],
        f.[Created],
        p.[UserID]
FROM    [dbo].[t_company] a
        INNER JOIN
        [dbo].[t_usercompany] b
        ON a.[cid] = b.[cid]
        INNER JOIN
        [dbo].[t_f_PAR] p
        ON b.[username] = p.[userid]
        INNER JOIN
        [dbo].[t_ArcForm] f
        ON p.[FormID] = f.[ItemID]
WHERE   f.[FormType] = 30

SELECT  a.[agentID] AS 'ID',
        a.[name] AS 'Name',
        a.[createdDate] AS 'Policy Create Date',
        a.[policyID] AS 'Policy ID',
        a.[fileNumber] AS 'File Number',
        p.[parID] AS 'PAR ID',
        a.[maxCoverage] AS 'Limit',
        a.[liability] AS 'Policy Amount',
        p.[amount] AS 'Requested Amount',
        p.[amount] - a.[liability] AS 'Difference',
        CASE 
          WHEN p.[approvedID] = 0  THEN 'New'
          WHEN p.[approvedID] = 10 THEN 'UnderReview'
          WHEN p.[approvedID] = 50 THEN 'Approved'
          WHEN p.[approvedID] = 60 THEN 'Denied'
          WHEN p.[approvedID] = 70 THEN 'Complete'
          WHEN p.[approvedID] = 80 THEN 'Cancelled'
          WHEN p.[approvedID] = 99 THEN 'Closed'
        END AS 'Status',
        p.[UserID] AS 'User ID',
        a.[policyIssuedEffDate] AS 'Policy Effective Date',
        p.[parDate] AS 'Request Submit Date',
        p.[approveDate] AS 'Request Approve Date'
FROM    ##agentLimit a
        LEFT OUTER JOIN
        @parTable p
        ON  a.[fileNumber] = p.[fileNumber]
        AND a.[agentID] = p.[agentID]
WHERE   YEAR(a.[createdDate]) = @year
AND     p.[parID] IS NULL
ORDER BY p.[amount] - a.[liability]
