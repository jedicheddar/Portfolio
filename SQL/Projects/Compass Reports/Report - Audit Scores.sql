
  CREATE TABLE #qarTable
  (
    [agentID] VARCHAR(20),
    [auditType] VARCHAR(20),
    [qarScore] INTEGER,
    [errScore] INTEGER,
    [auditDate] DATETIME,
    [auditYear] INTEGER,
    [seq] INTEGER
  )

  INSERT INTO #qarTable ([agentID],[auditType],[qarScore],[errScore],[auditDate],[auditYear],[seq])
  SELECT  q.[agentID],
          q.[auditType],
          q.[score] AS [qarScore],
          s.[score] AS [errScore],
          COALESCE(q.[auditReviewDate],q.[auditStartDate]) AS [auditDate],
          YEAR(COALESCE(q.[auditReviewDate],q.[auditStartDate])) AS [auditYear],
          ROW_NUMBER() OVER(PARTITION BY q.[agentID] ORDER BY COALESCE(q.[auditReviewDate],q.[auditStartDate]) DESC) AS [seq]
  FROM    [dbo].[qar] q LEFT OUTER JOIN
          [dbo].[qarsection] s
  ON      q.[qarID] = s.[qarID]
  AND     s.[sectionID] = 6
  WHERE   q.[stat] = 'C'
  AND     q.[auditType] IN ('Q','E')
  AND     q.[score] > 0
  AND     s.[score] > 0
  
  SELECT  a.[name] AS [Agent Name],
          a.[stateID] AS [State],
          q1.[qarScore] AS [2018 QAR Score],
          q1.[errScore] AS [2018 ERR Score],
          q2.[qarScore] AS [2017 QAR Score],
          q2.[errScore] AS [2017 ERR Score],
          q3.[qarScore] AS [2016 QAR Score],
          q3.[errScore] AS [2016 ERR Score]
  FROM    [dbo].[agent] a LEFT OUTER JOIN
          #qarTable q1 
  ON      a.[agentID] = q1.[agentID]
  AND     q1.[auditYear] = 2018 LEFT OUTER JOIN
          #qarTable q2
  ON      a.[agentID] = q2.[agentID]
  AND     q2.[auditYear] = 2017 LEFT OUTER JOIN
          #qarTable q3
  ON      a.[agentID] = q3.[agentID]
  AND     q3.[auditYear] = 2016
  ORDER BY a.[agentID]

  DROP TABLE #qarTable