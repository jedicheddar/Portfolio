USE [COMPASS]
SET ANSI_WARNINGS OFF;

DECLARE @startDate DATETIME = NULL,
        @loopDate DATETIME = NULL,
        @sql NVARCHAR(MAX) = '',
        @case NVARCHAR(MAX) = '',
        @index INTEGER = 1

-- Get the earliest active date in the table
SELECT @startDate = MIN([activeDate]) FROM [dbo].[agent]
--SELECT @startDate = DATEADD(MONTH,-3,GETDATE())

-- Create a temporary table
CREATE TABLE #remitTable
(
  [stateID] VARCHAR(50),
  [agentID] VARCHAR(50),
  [name] VARCHAR(MAX),
  [stat] VARCHAR(50),
  [activeDate] DATETIME
)

-- Create a variable number of columns from the earliest active date until today by month
SET @sql = N'ALTER TABLE #remitTable ADD'
SET @case = N'SELECT ''"'' + [stateID] + ''",'' AS [State],''="'' + [agentID] + ''",'' AS [Agent ID],''"'' + [name] + ''",'' AS [Agent Name],''"'' + [stat] + ''",'' AS [Status],''"'' + CONVERT(VARCHAR,[activeDate],101) + ''",'' AS [Active Date],'
WHILE @index <= DATEDIFF(MONTH,@startDate,GETDATE())
BEGIN
  SET @loopDate = DATEADD(MONTH,@index,@startDate)
  SET @sql += N' [' + RIGHT('0000' + CONVERT(VARCHAR,YEAR(@loopDate)), 4) + RIGHT('00' + CONVERT(VARCHAR,MONTH(@loopDate)), 2) + '] DECIMAL(18,2),'
  SET @case += N' + ISNULL(CONVERT(VARCHAR,[' + RIGHT('0000' + CONVERT(VARCHAR,YEAR(@loopDate)), 4) + RIGHT('00' + CONVERT(VARCHAR,MONTH(@loopDate)), 2) + ']) + '','','''')'
  SET @index += 1
END
SET @sql = SUBSTRING(@sql,1,LEN(@sql) - 1)
SET @case += ' FROM #remitTable'
PRINT @case
EXEC sp_executesql @sql

-- Create a temporary table for inserting the net premium
CREATE TABLE #netTable
(
  [agentID] VARCHAR(50),
  [periodID] INTEGER,
  [netPremium] DECIMAL(18,2)
)

INSERT INTO #netTable ([agentID],[periodID],[netPremium])
SELECT  a.[agentID],
        a.[periodID],
        ISNULL(b.[net],0)
FROM    (
        SELECT  a.[agentID],
                p.[periodID]
        FROM    [dbo].[agent] a CROSS APPLY
                (
                SELECT  [periodID]
                FROM    [dbo].[period]
                WHERE   [startDate] > a.[activeDate]
                ) p
        ) a LEFT OUTER JOIN
        (
        SELECT  b.[agentID],
                b.[periodID],
                SUM(bf.[netDelta]) AS [net]
        FROM    [dbo].[batch] b INNER JOIN
                [dbo].[batchform] bf
        ON      b.[batchID] = bf.[batchID]
        GROUP BY b.[agentID],b.[periodID]
        ) b
ON      b.[periodID] = a.[periodID]
AND     b.[agentID] = a.[agentID]

-- Get the columns and insert into remit table
DECLARE @columns AS NVARCHAR(MAX)
SELECT @columns = COALESCE(@columns + ',','') + QUOTENAME([periodID]) FROM (SELECT [periodID] FROM #netTable GROUP BY [periodID]) n
SET @sql = N'INSERT INTO #remitTable ([stateID],[agentID],[name],[stat],[activeDate],' + @columns + ') SELECT [stateID],[agentID],[name],[stat],[activeDate],' + @columns + ' FROM (SELECT a.[stateID],a.[agentID],a.[name],a.[stat],COALESCE(a.[activeDate],a.[contractDate]) AS [activeDate],n.[periodID],n.[netPremium] FROM [dbo].[agent] a INNER JOIN #netTable n ON a.[agentID] = n.[agentID]) a PIVOT(SUM([netPremium]) FOR [periodID] IN (' + @columns + ')) p'

--Execute dynamic query
EXEC sp_executesql @sql

-- Delete rows with no active date
DELETE FROM #remitTable WHERE [activeDate] IS NULL

EXEC sp_executesql @case

DROP TABLE #remitTable
DROP TABLE #netTable
