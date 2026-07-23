DECLARE @file VARCHAR(30) = ''

IF (@file <> '')
BEGIN
  DECLARE @action VARCHAR(50) = ''
  SELECT @action=[action] FROM [dbo].[sysaction] WHERE [progExec] LIKE '%' + @file + '%'

  SELECT  @file,
          @action,
          COUNT(*),
          (SELECT [uid] FROM [dbo].[syslog] WHERE [action] = @action AND [createdate] = MAX(l.[createdate])),
          (SELECT [applicationID] FROM [dbo].[syslog] WHERE [action] = @action AND [createdate] = MAX(l.[createdate]))
  FROM    [dbo].[syslog] l
  WHERE   [action] = @action
END