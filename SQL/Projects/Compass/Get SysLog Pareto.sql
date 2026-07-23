USE [COMPASS]
  
DECLARE @daysBack INTEGER = 30

CREATE TABLE #action
(
  [app] VARCHAR(50),
  [action] VARCHAR(50),
  [times] INTEGER
)

CREATE TABLE #pareto
(
  [seq] INTEGER,
  [app] VARCHAR(50),
  [action] VARCHAR(50),
  [times] INTEGER,
  [pareto] DECIMAL(18,3)
)

INSERT INTO #action ([action], [times])
SELECT  l.[action],
        COUNT(*) AS [times]
FROM    [dbo].[syslog] l
WHERE   l.[createdate] > DATEADD(DAY, @daysBack * -1, GETDATE())
AND     l.[action] NOT LIKE 'batch%'
AND     l.[action] NOT LIKE 'cron%'
AND     l.[action] <> 'ping'
GROUP BY l.[action]

INSERT INTO #pareto ([seq], [action], [times], [pareto])
SELECT  ROW_NUMBER() OVER (ORDER BY a.[times] DESC),
        a.[action],
        a.[times],
        CONVERT(DECIMAL(18,3), CONVERT(DECIMAL(18,3), a.[times]) / CONVERT(DECIMAL(18,3), b.[total]) * 100) AS [pareto]
FROM    #action a CROSS JOIN
        (
        SELECT  SUM([times]) AS [total]
        FROM    #action
        ) b
ORDER BY [times] DESC

SELECT  p1.[action],
        p1.[times],
        p1.[pareto],
        SUM(p2.[pareto]) AS [cumulative]
FROM    #pareto p1 INNER JOIN 
        #pareto p2
ON      p1.[seq] >= p2.[seq]
GROUP BY p1.[action], p1.[times], p1.[pareto], p1.[seq]
ORDER BY p1.[seq]

DROP TABLE #action
DROP TABLE #pareto