DECLARE @queueID int = 0,
        @param VARCHAR(MAX) = '',
        @reset BIT = 0

IF (@queueID > 0)
BEGIN
  IF @reset = 1
  BEGIN
    UPDATE [sysqueue] SET [stat] = 'Q', [startDate] = null, [endDate] = null WHERE [queueID] = @queueID
    UPDATE [sysqueueitem] SET [stat] = '', [faultMsg] = '' WHERE [queueID] = @queueID
  END

  SELECT * FROM [sysqueue] WHERE [queueID] = @queueID
  SELECT * FROM [sysqueueitem] WHERE [queueID] = @queueID
END
ELSE
  SELECT s.*, si.* FROM [sysqueue] s INNER JOIN [sysqueueitem] si ON s.[queueID] = si.[queueID] WHERE si.[parameters] LIKE '%' + @param + '%' ORDER BY s.[queueID] DESC