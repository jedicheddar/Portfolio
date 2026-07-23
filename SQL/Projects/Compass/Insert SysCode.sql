USE [COMPASS]
GO
DECLARE @codeType VARCHAR(32) = '',
        @code VARCHAR(32),
        @count INTEGER

IF (@codeType != '')
BEGIN
  CREATE TABLE #codeTable ([code] VARCHAR(32),[description] VARCHAR(100),[comment] VARCHAR(MAX))
  INSERT INTO #codeTable ([code],[description],[comment]) VALUES ('','','')

  SELECT RowNum = ROW_NUMBER() OVER(ORDER BY [code]),* INTO #temp FROM #codeTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  WHILE @Iter <= @MaxRownum
  BEGIN
    SELECT @code=[code] FROM #temp WHERE [RowNum] = @Iter
    SELECT @count=COUNT(*) FROM [dbo].[syscode] WHERE [codeType] = @codeType AND [code] = @code

    IF (@code <> '')
    BEGIN
      IF (@count = 0) -- New code
      BEGIN
        INSERT INTO [dbo].[syscode] ([codeType],[code],[description],[comments])
        SELECT  @codeType,
                [code],
                [description],
                [comment]
        FROM    #temp 
        WHERE   [RowNum] = @Iter
      END

      UPDATE  [dbo].[syscode]
      SET     [description] = ca.[description],
              [comments] = ca.[comment]
      FROM    #temp ca INNER JOIN
              [dbo].[syscode] code
      ON      ca.[code] = code.[code]

    END
    SET @Iter = @Iter + 1
  END
  SELECT  *
  FROM    [dbo].[syscode]
  WHERE   [codeType] = @codeType
  ORDER BY [code]

  DROP TABLE #temp
  DROP TABLE #codeTable
END
GO