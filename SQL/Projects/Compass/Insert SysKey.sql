GO

DECLARE @type VARCHAR(30) = '',
        @index INTEGER = 0,
        @table VARCHAR(30) = '',
        @column VARCHAR(30) = ''

DECLARE @tempType VARCHAR(30) = '',
        @count INTEGER = 0

IF (@type <> '')
BEGIN
  SELECT @tempType=[type] FROM [dbo].[syskey] WHERE [type]=@type

  IF (@tempType = '')
  BEGIN
  INSERT INTO [dbo].[syskey]
             ([type]
             ,[seq]
             ,[changeDate]
             ,[uid])
       VALUES
             (@type
             ,@index
             ,getdate()
             ,'joliver@alliantnational.com')
  END
  ELSE
  BEGIN
    IF (@table = '')
    BEGIN
      UPDATE [dbo].[syskey]
      SET    [seq]=@index
            ,[changeDate]=getdate()
      WHERE  [type]=@type
    END
    ELSE
    BEGIN
      DECLARE @sql NVARCHAR(MAX)
      IF (@column <> '')
        SET @sql = N'SELECT @count=MAX([' + @column + ']) FROM [dbo].[' + @table + ']'
      ELSE
        SET @sql = N'SELECT @count=COUNT(*) FROM [dbo].[' + @table + ']'
      EXEC sp_executesql @sql, N'@count INTEGER OUTPUT', @count=@count OUTPUT
      UPDATE [dbo].[syskey]
      SET    [seq]=@count
            ,[changeDate]=getdate()
      WHERE  [type]=@type
    END
  END

  SELECT * FROM [dbo].[syskey] WHERE [type]=@type
END
ELSE
BEGIN
  SELECT  [type],
          [seq],
          [changedate],
          [uid]
  FROM    [COMPASS].[dbo].[syskey]
  ORDER BY [type]
END

