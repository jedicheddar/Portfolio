/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @action VARCHAR(100) = '',
        @user VARCHAR(100) = '',
        @time INTEGER = 0

IF (@action <> '')
BEGIN
  SELECT  COUNT(*) AS [timesRan],
          [uid],
          [applicationID],
          MAX([createdate]) AS [lastDate]
  FROM    [dbo].[syslog]
  WHERE   [action] LIKE '%' + @action + '%'
  AND     [uid] = CASE WHEN @user = '' THEN [uid] ELSE @user END
  AND     [createdate] > '2021-01-01'
  GROUP BY [uid],[action],[applicationID]
  ORDER BY count(*) DESC
END
ELSE
BEGIN
  SELECT  [uid],
          [action],
          COUNT(*) AS [timesRan]
  FROM    [dbo].[syslog]
  WHERE   [uid] = CASE WHEN @user = '' THEN [uid] ELSE @user END
  GROUP BY [uid],[action]
  ORDER BY count(*) DESC
END