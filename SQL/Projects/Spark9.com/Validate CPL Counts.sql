USE [alliant]

DECLARE @month INTEGER = 1,
        @year INTEGER = 2019

SELECT * INTO #TransTable FROM [dbo].[TransactionLog] WHERE [TransactionServiceType] = 'cplIssue' AND MONTH([TimeStamp]) = @month AND YEAR([TimeStamp]) = @year
SELECT * INTO #CPLTable FROM [dbo].[t_ICL] WHERE YEAR([ICLDate]) = 2019 AND MONTH([ICLDate]) = 1

SELECT  c.*
FROM    [dbo].[t_company] a INNER JOIN
        #CPLTable c
ON      a.[cid] = c.[EscrowID]
WHERE   c.[ICLID] NOT IN (SELECT [CPLNumber] FROM #TransTable)

DROP TABLE #TransTable
DROP TABLE #CPLTable