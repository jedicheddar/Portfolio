USE [COMPASS]
GO
DECLARE @codeType VARCHAR(32) = 'ClaimAttribute',
        @code VARCHAR(32),
        @maxCode INTEGER,
        @count INTEGER

IF (@codeType != '')
BEGIN
  CREATE TABLE #claimAttr ([code] VARCHAR(32),[description] VARCHAR(100),[type] VARCHAR(50),[comment] VARCHAR(100))
  INSERT INTO #claimAttr VALUES ('','','list','The list is in the sysprop table')

  SELECT RowNum = ROW_NUMBER() OVER(ORDER BY [code]),* INTO #temp FROM #claimAttr

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  WHILE @Iter <= @MaxRownum
  BEGIN
    SELECT @code=[code] FROM #temp WHERE [RowNum] = @Iter
    SELECT @count=COUNT(*) FROM [dbo].[syscode] WHERE [codeType] = @codeType AND [code] = @code

    IF (@code = '' OR @count = 0) -- New attribute
    BEGIN
      -- We need to get the last code
      SELECT @maxCode=MAX(CONVERT(INTEGER,SUBSTRING([code],3,5)))+1 FROM [dbo].[syscode] WHERE [codeType] = @codeType

      INSERT INTO [dbo].[syscode] ([codeType],[code],[description],[type],[comments])
      SELECT  @codeType,
              'CA' + CONVERT(VARCHAR,@maxCode),
              [description],
              [type],
              [comment]
      FROM    #temp 
      WHERE   [RowNum] = @Iter
    END

    UPDATE  [dbo].[syscode]
    SET     [description] = ca.[description],
            [type] = ca.[type],
            [comments] = ca.[comment]
    FROM    #temp ca INNER JOIN
            [dbo].[syscode] code
    ON      ca.[code] = code.[code]

    SET @Iter = @Iter + 1
  END
  SELECT  *
  FROM    [dbo].[syscode]
  WHERE   [codeType] = @codeType
  ORDER BY CONVERT(INTEGER,SUBSTRING([code],3,5))

  DROP TABLE #temp
  DROP TABLE #claimAttr
END
GO