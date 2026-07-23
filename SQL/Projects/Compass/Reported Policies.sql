SET NOCOUNT ON

DECLARE @state        VARCHAR(20) = '',
        @startEffDate DATETIME    = '',
        @endEffDate   DATETIME    = '',
        @reported     BIT         = 0

IF @startEffDate = ''
 SET @startEffDate = DATEADD(YEAR, -2, GETDATE())

IF @endEffDate = ''
 SET @endEffDate = GETDATE()

CREATE TABLE #policyList ([policyID] INTEGER)
INSERT INTO #policyList ([policyID]) VALUES (1471578)
INSERT INTO #policyList ([policyID]) VALUES (1485049)
INSERT INTO #policyList ([policyID]) VALUES (1509537)
INSERT INTO #policyList ([policyID]) VALUES (1519729)
INSERT INTO #policyList ([policyID]) VALUES (1512984)
INSERT INTO #policyList ([policyID]) VALUES (1520309)
INSERT INTO #policyList ([policyID]) VALUES (1528551)
INSERT INTO #policyList ([policyID]) VALUES (1550695)
INSERT INTO #policyList ([policyID]) VALUES (1574998)
INSERT INTO #policyList ([policyID]) VALUES (1647655)
INSERT INTO #policyList ([policyID]) VALUES (1657789)
INSERT INTO #policyList ([policyID]) VALUES (1670946)
INSERT INTO #policyList ([policyID]) VALUES (1661147)
INSERT INTO #policyList ([policyID]) VALUES (1704522)
INSERT INTO #policyList ([policyID]) VALUES (1674210)
INSERT INTO #policyList ([policyID]) VALUES (1676997)
INSERT INTO #policyList ([policyID]) VALUES (1722382)
INSERT INTO #policyList ([policyID]) VALUES (1715877)
INSERT INTO #policyList ([policyID]) VALUES (1717580)
INSERT INTO #policyList ([policyID]) VALUES (1745753)
INSERT INTO #policyList ([policyID]) VALUES (1775675)
INSERT INTO #policyList ([policyID]) VALUES (1814282)
INSERT INTO #policyList ([policyID]) VALUES (1837202)
INSERT INTO #policyList ([policyID]) VALUES (1850355)
INSERT INTO #policyList ([policyID]) VALUES (1934374)
INSERT INTO #policyList ([policyID]) VALUES (2110925)
INSERT INTO #policyList ([policyID]) VALUES (2045566)
INSERT INTO #policyList ([policyID]) VALUES (2121620)
INSERT INTO #policyList ([policyID]) VALUES (1948435)
INSERT INTO #policyList ([policyID]) VALUES (1953764)
INSERT INTO #policyList ([policyID]) VALUES (1961602)
INSERT INTO #policyList ([policyID]) VALUES (1991503)
INSERT INTO #policyList ([policyID]) VALUES (2045597)
INSERT INTO #policyList ([policyID]) VALUES (2119354)
INSERT INTO #policyList ([policyID]) VALUES (1992378)
INSERT INTO #policyList ([policyID]) VALUES (2030916)
INSERT INTO #policyList ([policyID]) VALUES (2106561)
INSERT INTO #policyList ([policyID]) VALUES (2109555)
INSERT INTO #policyList ([policyID]) VALUES (2086297)
INSERT INTO #policyList ([policyID]) VALUES (2101295)
INSERT INTO #policyList ([policyID]) VALUES (2107943)
INSERT INTO #policyList ([policyID]) VALUES (2160009)
INSERT INTO #policyList ([policyID]) VALUES (2137675)
INSERT INTO #policyList ([policyID]) VALUES (2145751)
INSERT INTO #policyList ([policyID]) VALUES (2179362)
INSERT INTO #policyList ([policyID]) VALUES (2157060)
INSERT INTO #policyList ([policyID]) VALUES (2220539)
INSERT INTO #policyList ([policyID]) VALUES (2265104)
INSERT INTO #policyList ([policyID]) VALUES (2236540)
INSERT INTO #policyList ([policyID]) VALUES (2279271)

DECLARE @count INTEGER = 0
SELECT @count=COUNT(*) FROM #policyList

-- For a policy list
IF (@count > 0)
BEGIN
  SELECT  a.[agentID] AS [Agent ID],
          a.[name] AS [Agent Name],
          p.[policyID] AS [Policy Number],
          p.[fileNumber] AS [File Number],
          p.[effDate] AS [Effective Date],
          p.[issueDate] AS [Issued Date],
          (SELECT [policyType] FROM [tempdb].[dbo].[policyforms] WHERE [PFormID] = p.[issuedFormID]) AS [Policy Type],
          (SELECT [statCode] FROM [batchform] WHERE [policyID] = p.[policyID] AND [formType] = 'P') AS [Stat Code],
          p.[liabilityAmount] AS [Liability Amount],
          p.[grossPremium] AS [Gross Premium],
          p.[netPremium] AS [Net Premium],
          ISNULL((SELECT [description] FROM [stateform] WHERE [stateID] = p.[stateID] AND [formID] = e.[formID]), '') AS [Endorsement],
          ISNULL(e.[grossPremium],0) AS [Endorsement Gross],
          ISNULL(e.[netPremium],0) AS [Endorsement Net]
  FROM    [policy] p INNER JOIN
          [agent] a
  ON      p.[agentID] = a.[agentID] LEFT OUTER JOIN
          [endorsement] e
  ON      p.[policyID] = e.[policyID] INNER JOIN
          [batchform] bf
  ON      p.[policyID] = bf.[policyID]
  AND     bf.[formType] = 'P'
  WHERE   p.[policyID] IN (SELECT [policyID] FROM #policyList)
  ORDER BY p.[policyID]
END
--For the other criteria
ELSE
BEGIN
  SELECT  [policyID] AS [Policy ID],
          [effDate] AS [Effective Date]
  FROM    [policy] p
  WHERE   p.[stateID] = CASE WHEN @state = '' THEN p.[stateID] ELSE @state END
  AND     p.[effDate] BETWEEN @startEffDate and @endEffDate
  AND     p.[stat] = CASE WHEN @reported = 1 THEN 'P' ELSE 'I' END
END

DROP TABLE #policyList