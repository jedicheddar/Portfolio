GO
SET ANSI_WARNINGs OFF

DECLARE @code VARCHAR(50) = '36',
        @codeType VARCHAR(50) = 'ClaimDescription',
        @startDate DATETIME = '2013-01-01 00:00:00',
        @endDate DATETIME = '2016-12-31 23:59:59'

CREATE TABLE #result
(
  agentName VARCHAR(500),
  claimID INTEGER,
  claimType VARCHAR(50),
  claimStatus VARCHAR(10),
  agentError VARCHAR(10),
  rowType VARCHAR(50),
  State1 DECIMAL(18,2),
  State2 DECIMAL(18,2),
  State3 DECIMAL(18,2),
  State4 DECIMAL(18,2),
  State5 DECIMAL(18,2)
)

-- Insert into the table
INSERT INTO #result
SELECT  [agentName],
        [claimID],
        [claimType],
        [claimStatus],
        [agentError],
        'ClaimsByCode' AS [rowType],
        SUM([AZ]) AS [State1],SUM([CO]) AS [State2],SUM([FL]) AS [State3],SUM([MO]) AS [State4],SUM([TX]) AS [State5]
FROM    (
        SELECT  agent.[agentID],
                agent.[name] AS 'agentName',
                claim.[claimID],
                claim.[type] AS 'claimType',
                claim.[agentError] AS 'agentError',
                CASE
                  WHEN claim.[stat] = 'C' AND claim.[dateClosed] > @endDate THEN 'O'
                  ELSE claim.[stat]
                END AS 'claimStatus',
                claim.[stateID],
                aptrx.[transAmount]
        FROM    [dbo].[claim] claim INNER JOIN
                [dbo].[agent] agent
        ON      claim.[agentID] = agent.[agentID] INNER JOIN
                [dbo].[aptrx] aptrx
        ON      claim.[claimID] = CONVERT(INTEGER,aptrx.[refID]) INNER JOIN
                [dbo].[claimcode] cc
        ON      claim.[claimID] = cc.[claimID]
        WHERE   claim.[stateID] IN ('AZ','CO','FL','MO','TX')
        AND     cc.[code] = @code
        AND     cc.[codeType] = @codeType
        AND     claim.[dateCreated] BETWEEN @startDate AND @endDate
        AND    (claim.[dateClosed] IS NULL OR claim.[dateClosed] < @endDate)
        ) src
        PIVOT
        (
        SUM([transAmount])
        FOR [stateID] IN ([AZ],[CO],[FL],[MO],[TX])
        ) p
GROUP BY [agentName],[claimID],[claimType],[claimStatus],[agentError]
UNION ALL
SELECT  '',
        '',
        '',
        '',
        '',
        'ClaimsTotal',
        SUM([AZ]) AS [State1],SUM([CO]) AS [State2],SUM([FL]) AS [State3],SUM([MO]) AS [State4],SUM([TX]) AS [State5]
FROM    (
        SELECT  agent.[agentID],
                agent.[name] AS 'agentName',
                claim.[stateID],
                aptrx.[transAmount]
        FROM    [dbo].[claim] claim INNER JOIN
                [dbo].[agent] agent
        ON      claim.[agentID] = agent.[agentID] INNER JOIN
                [dbo].[aptrx] aptrx
        ON      claim.[claimID] = CONVERT(INTEGER,aptrx.[refID])
        WHERE   claim.[stateID] IN ('AZ','CO','FL','MO','TX')
        AND     claim.[dateCreated] BETWEEN @startDate AND @endDate
        AND    (claim.[dateClosed] IS NULL OR claim.[dateClosed] < @endDate)
        ) src
        PIVOT
        (
        SUM([transAmount])
        FOR [stateID] IN ([AZ],[CO],[FL],[MO],[TX])
        ) p

-- Get the report
SELECT  'State Totals' AS 'Agent',
        '' AS 'Claim #',
        '' AS 'Claim Type',
        '' AS 'Claim Status',
        '' AS 'Agent Error',
        [State1] AS 'AZ',
        [State2] AS 'CO',
        [State3] AS 'FL',
        [State4] AS 'MO',
        [State5] AS 'TX'
FROM    #result
WHERE   [rowType] = 'ClaimsTotal'
UNION ALL
SELECT  'State % of Totals',
        '',
        '',
        '',
        '',
        CONVERT(DECIMAL(18,2),b.[AZ] / a.[AZ] * 100),
        CONVERT(DECIMAL(18,2),b.[CO] / a.[CO] * 100),
        CONVERT(DECIMAL(18,2),b.[FL] / a.[FL] * 100),
        CONVERT(DECIMAL(18,2),b.[MO] / a.[MO] * 100),
        CONVERT(DECIMAL(18,2),b.[TX] / a.[TX] * 100)
FROM    (
        SELECT  [State1] AS 'AZ',
                [State2] AS 'CO',
                [State3] AS 'FL',
                [State4] AS 'MO',
                [State5] AS 'TX'
        FROM    #result
        WHERE   [rowType] = 'ClaimsTotal'
        ) a CROSS JOIN
        (
        SELECT  SUM([State1]) AS 'AZ',
                SUM([State2]) AS 'CO',
                SUM([State3]) AS 'FL',
                SUM([State4]) AS 'MO',
                SUM([State5]) AS 'TX'
        FROM    #result
        WHERE   [rowType] = 'ClaimsByCode'
        GROUP BY [rowType]
        ) b
UNION ALL
SELECT  [agentName],
        CONVERT(VARCHAR,[claimID]),
        [claimType],
        [claimStatus],
        [agentError],
        [State1],
        [State2],
        [State3],
        [State4],
        [State5]
FROM    #result
WHERE   [rowType] = 'ClaimsByCode'
UNION ALL
SELECT  '',
        '',
        '',
        '',
        '',
        SUM([State1]),
        SUM([State2]),
        SUM([State3]),
        SUM([State4]),
        SUM([State5])
FROM    #result
WHERE   [rowType] = 'ClaimsByCode'

SELECT  a.[total] AS 'Grand Total',
        b.[total] AS 'Reason Total',
        CONVERT(DECIMAL(18,2),b.[total] / a.[total] * 100) AS 'Percent of Total'
FROM    (
        SELECT  [State1] + 
                [State2] + 
                [State3] + 
                [State4] + 
                [State5] AS 'total'
        FROM    #result
        WHERE   [rowType] = 'ClaimsTotal'
        ) a CROSS JOIN
        (
        SELECT  SUM([State1]) + 
                SUM([State2]) + 
                SUM([State3]) + 
                SUM([State4]) + 
                SUM([State5]) AS 'total'
        FROM    #result
        WHERE   [rowType] = 'ClaimsByCode'
        GROUP BY [rowType]
        ) b
UNION ALL
SELECT  a.[total] AS 'Grand Total',
        b.[total] AS 'Reason Total',
        CONVERT(DECIMAL(18,2),b.[total] / a.[total] * 100) AS 'Percent of Total'
FROM    (
        SELECT  COUNT([claimID]) AS 'total'
        FROM    [dbo].[claim]
        WHERE   [dateCreated] BETWEEN @startDate AND @endDate
        AND    ([dateClosed] IS NULL OR [dateClosed] < @endDate)
        ) a CROSS JOIN
        (
        SELECT  COUNT([claimID]) AS 'total'
        FROM    #result
        WHERE   [rowType] = 'ClaimsByCode'
        GROUP BY [rowType]
        ) b

SELECT  [description] AS 'Report Title'
FROM    [dbo].[syscode]
WHERE   [code] = @code
AND     [codeType] = @codeType

DROP TABLE #result
GO
