USE [COMPASS]

DECLARE @category VARCHAR(20) = 'G',
        @cplCategory VARCHAR(20)

IF @category = 'G'
  SET @cplCategory = 'I'

IF @category = 'N'
  SET @cplCategory = 'T'

CREATE TABLE #premium (
	[agentID] [varchar](50) NULL,
	[month1]  [decimal](18, 2) NULL,
	[month2]  [decimal](18, 2) NULL,
	[month3]  [decimal](18, 2) NULL,
	[month4]  [decimal](18, 2) NULL,
	[month5]  [decimal](18, 2) NULL,
	[month6]  [decimal](18, 2) NULL,
	[month7]  [decimal](18, 2) NULL,
	[month8]  [decimal](18, 2) NULL,
	[month9]  [decimal](18, 2) NULL,
	[month10] [decimal](18, 2) NULL,
	[month11] [decimal](18, 2) NULL,
	[month12] [decimal](18, 2) NULL
)

CREATE TABLE #cpl (
	[agentID] [varchar](50) NULL,
	[month1]  [decimal](18, 2) NULL,
	[month2]  [decimal](18, 2) NULL,
	[month3]  [decimal](18, 2) NULL,
	[month4]  [decimal](18, 2) NULL,
	[month5]  [decimal](18, 2) NULL,
	[month6]  [decimal](18, 2) NULL,
	[month7]  [decimal](18, 2) NULL,
	[month8]  [decimal](18, 2) NULL,
	[month9]  [decimal](18, 2) NULL,
	[month10] [decimal](18, 2) NULL,
	[month11] [decimal](18, 2) NULL,
	[month12] [decimal](18, 2) NULL,
	[state1]  [decimal](18, 2) NULL,
	[state2]  [decimal](18, 2) NULL,
	[state3]  [decimal](18, 2) NULL,
	[state4]  [decimal](18, 2) NULL,
	[state5]  [decimal](18, 2) NULL,
	[state6]  [decimal](18, 2) NULL,
	[state7]  [decimal](18, 2) NULL,
	[state8]  [decimal](18, 2) NULL,
	[state9]  [decimal](18, 2) NULL,
	[state10] [decimal](18, 2) NULL,
	[state11] [decimal](18, 2) NULL,
	[state12] [decimal](18, 2) NULL
)

CREATE TABLE #ratio (
	[agentID] [varchar](50) NULL,
	[month1]  [decimal](18, 2) NULL,
	[month2]  [decimal](18, 2) NULL,
	[month3]  [decimal](18, 2) NULL,
	[month4]  [decimal](18, 2) NULL,
	[month5]  [decimal](18, 2) NULL,
	[month6]  [decimal](18, 2) NULL,
	[month7]  [decimal](18, 2) NULL,
	[month8]  [decimal](18, 2) NULL,
	[month9]  [decimal](18, 2) NULL,
	[month10] [decimal](18, 2) NULL,
	[month11] [decimal](18, 2) NULL,
	[month12] [decimal](18, 2) NULL
)

-- Get the premium values
INSERT INTO #premium ([agentID],[month1],[month2],[month3],[month4],[month5],[month6],[month7],[month8],[month9],[month10],[month11],[month12])
SELECT  [agentID],
        [month2]  AS [month1],
        [month3]  AS [month2],
        [month4]  AS [month3],
        [month5]  AS [month4],
        [month6]  AS [month5],
        [month7]  AS [month6],
        [month8]  AS [month7],
        [month9]  AS [month8],
        [month10] AS [month9],
        [month11] AS [month10],
        [month12] AS [month11],
        [month12]
FROM    [dbo].[GetActivityTable](@category,2019)
WHERE   [type] = 'A'

-- Get the cpl values
INSERT INTO #cpl ([agentID],[month1],[month2],[month3],[month4],[month5],[month6],[month7],[month8],[month9],[month10],[month11],[month12],[state1],[state2],[state3],[state4],[state5],[state6],[state7],[state8],[state9],[state10],[state11],[state12])
SELECT  [agentID],
        [month1],
        [month2],
        [month3],
        [month4],
        [month5],
        [month6],
        [month7],
        [month8],
        [month9],
        [month10],
        [month11],
        [month12],
        [state1],
        [state2],
        [state3],
        [state4],
        [state5],
        [state6],
        [state7],
        [state8],
        [state9],
        [state10],
        [state11],
        [state12]
FROM    [dbo].[GetActivityTable](@cplCategory,2019) a INNER JOIN
        (
        SELECT  [stateID],
                SUM([month1])  / COUNT([agentID]) AS [state1],
                SUM([month2])  / COUNT([agentID]) AS [state2],
                SUM([month3])  / COUNT([agentID]) AS [state3],
                SUM([month4])  / COUNT([agentID]) AS [state4],
                SUM([month5])  / COUNT([agentID]) AS [state5],
                SUM([month6])  / COUNT([agentID]) AS [state6],
                SUM([month7])  / COUNT([agentID]) AS [state7],
                SUM([month8])  / COUNT([agentID]) AS [state8],
                SUM([month9])  / COUNT([agentID]) AS [state9],
                SUM([month10]) / COUNT([agentID]) AS [state10],
                SUM([month11]) / COUNT([agentID]) AS [state11],
                SUM([month12]) / COUNT([agentID]) AS [state12]
        FROM    [dbo].[GetActivityTable](@cplCategory,2019)
        WHERE   [type] = 'A'
        GROUP BY [stateID]
        ) s
ON      a.[stateID] = s.[stateID]
WHERE   [type] = 'A'
AND     [agentID] IN (SELECT [agentID] FROM #premium)

--Insert the ratio
INSERT INTO #ratio ([agentID],[month1],[month2],[month3],[month4],[month5],[month6],[month7],[month8],[month9],[month10],[month11],[month12])
SELECT  p.[agentID],
        CASE WHEN c.[state1]  = 0 THEN 0 ELSE p.[month1]  / (CASE WHEN c.[month1]  >= 25 THEN c.[month1]  ELSE c.[state1]  END) END AS [ratio1],
        CASE WHEN c.[state2]  = 0 THEN 0 ELSE p.[month2]  / (CASE WHEN c.[month2]  >= 25 THEN c.[month2]  ELSE c.[state2]  END) END AS [ratio2],
        CASE WHEN c.[state3]  = 0 THEN 0 ELSE p.[month3]  / (CASE WHEN c.[month3]  >= 25 THEN c.[month3]  ELSE c.[state3]  END) END AS [ratio3],
        CASE WHEN c.[state4]  = 0 THEN 0 ELSE p.[month4]  / (CASE WHEN c.[month4]  >= 25 THEN c.[month4]  ELSE c.[state4]  END) END AS [ratio4],
        CASE WHEN c.[state5]  = 0 THEN 0 ELSE p.[month5]  / (CASE WHEN c.[month5]  >= 25 THEN c.[month5]  ELSE c.[state5]  END) END AS [ratio5],
        CASE WHEN c.[state6]  = 0 THEN 0 ELSE p.[month6]  / (CASE WHEN c.[month6]  >= 25 THEN c.[month6]  ELSE c.[state6]  END) END AS [ratio6],
        CASE WHEN c.[state7]  = 0 THEN 0 ELSE p.[month7]  / (CASE WHEN c.[month7]  >= 25 THEN c.[month7]  ELSE c.[state7]  END) END AS [ratio7],
        CASE WHEN c.[state8]  = 0 THEN 0 ELSE p.[month8]  / (CASE WHEN c.[month8]  >= 25 THEN c.[month8]  ELSE c.[state8]  END) END AS [ratio8],
        CASE WHEN c.[state9]  = 0 THEN 0 ELSE p.[month9]  / (CASE WHEN c.[month9]  >= 25 THEN c.[month9]  ELSE c.[state9]  END) END AS [ratio9],
        CASE WHEN c.[state10] = 0 THEN 0 ELSE p.[month10] / (CASE WHEN c.[month10] >= 25 THEN c.[month10] ELSE c.[state10] END) END AS [ratio10],
        CASE WHEN c.[state11] = 0 THEN 0 ELSE p.[month11] / (CASE WHEN c.[month11] >= 25 THEN c.[month11] ELSE c.[state11] END) END AS [ratio11],
        CASE WHEN c.[state12] = 0 THEN 0 ELSE p.[month12] / (CASE WHEN c.[month12] >= 25 THEN c.[month12] ELSE c.[state12] END) END AS [ratio12]
FROM    #premium p INNER JOIN
        #cpl c
ON      p.[agentID] = c.[agentID]

SELECT  a.[agentID] AS [Agent],
        a.[name] AS [Name],
        a.[stateID] AS [State],
        CONVERT(INT,CASE WHEN r.[month1]  = 0 OR (r.[month1]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month1]  / r.[month1]  END) AS [Jan],
        CONVERT(INT,CASE WHEN r.[month2]  = 0 OR (r.[month2]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month2]  / r.[month2]  END) AS [Feb],
        CONVERT(INT,CASE WHEN r.[month3]  = 0 OR (r.[month3]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month3]  / r.[month3]  END) AS [Mar],
        CONVERT(INT,CASE WHEN r.[month4]  = 0 OR (r.[month4]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month4]  / r.[month4]  END) AS [Apr],
        CONVERT(INT,CASE WHEN r.[month5]  = 0 OR (r.[month5]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month5]  / r.[month5]  END) AS [May],
        CONVERT(INT,CASE WHEN r.[month6]  = 0 OR (r.[month6]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month6]  / r.[month6]  END) AS [Jun],
        CONVERT(INT,CASE WHEN r.[month7]  = 0 OR (r.[month7]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month7]  / r.[month7]  END) AS [Jul],
        CONVERT(INT,CASE WHEN r.[month8]  = 0 OR (r.[month8]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month8]  / r.[month8]  END) AS [Aug],
        CONVERT(INT,CASE WHEN r.[month9]  = 0 OR (r.[month9]  <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month9]  / r.[month9]  END) AS [Sep],
        CONVERT(INT,CASE WHEN r.[month10] = 0 OR (r.[month10] <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month10] / r.[month10] END) AS [Oct],
        CONVERT(INT,CASE WHEN r.[month11] = 0 OR (r.[month11] <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month11] / r.[month11] END) AS [Nov],
        CONVERT(INT,CASE WHEN r.[month12] = 0 OR (r.[month12] <= 0 AND @cplCategory = 'I') THEN 0 ELSE a.[month12] / r.[month12] END) AS [Dec]
FROM    (
        SELECT  *
        FROM    [dbo].[GetActivityTable] (@category,2020)
        WHERE   [type] = 'P'
        ) a INNER JOIN
        #ratio r
ON      a.[agentID] = r.[agentID]
ORDER BY [Agent]

DROP TABLE #premium
DROP TABLE #cpl
DROP TABLE #ratio