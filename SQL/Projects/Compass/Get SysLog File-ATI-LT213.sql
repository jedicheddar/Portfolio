DECLARE @file VARCHAR(30) = ''

IF (@file <> '')
BEGIN
  DECLARE @action VARCHAR(50) = ''
  SELECT @action=[action] FROM [dbo].[sysaction] WHERE [progExec] LIKE '%' + @file + '%'

  SELECT  @file AS [File],
          @action AS [Action],
          COUNT(*) AS [Count],
          (SELECT [uid] FROM [dbo].[syslog] WHERE [action] = @action AND [createdate] = MAX(l.[createdate])) AS [Last User],
          (SELECT [applicationID] FROM [dbo].[syslog] WHERE [action] = @action AND [createdate] = MAX(l.[createdate])) AS [Module]
  FROM    [dbo].[syslog] l
  WHERE   [action] = @action
END