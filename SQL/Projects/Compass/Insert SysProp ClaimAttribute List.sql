USE [COMPASS]
GO
DECLARE @appCode VARCHAR(20) = 'CLM',
        @objAction VARCHAR(100) = 'ClaimAttribute',
        @objProperty VARCHAR(100) = 'List',
        @objID VARCHAR(100) = '',
        @modifiedBy VARCHAR(100) = 'joliver@alliantnational.com',
        @count INTEGER = 0,
        @list VARCHAR(1000) = ''
        
CREATE TABLE #propTable (objValue VARCHAR(100))
INSERT INTO #propTable (objValue) VALUES ('')

SELECT '      ' AS [type],* INTO #validTable FROM [sysprop] WHERE 1=2

IF (@objID != '')
BEGIN
  SELECT RowNum = ROW_NUMBER() OVER(ORDER BY [objValue]),* INTO #temp FROM #propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  WHILE @Iter <= @MaxRownum
  BEGIN
    SELECT @list=@list + [objValue] + ',' FROM #temp WHERE RowNum = @Iter
    SET @Iter = @Iter + 1
  END
  SET @list = SUBSTRING(@list,1,LEN(@list)-1)

  IF (@list != '')
  BEGIN
    INSERT INTO #validTable
    SELECT  'Before',* 
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objProperty] = @objProperty
    AND     [objID] = @objID

    SELECT  @count=COUNT(*)
    FROM    #validTable
    IF (@count = 0) -- New item
      EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@list, @modifiedBy=@modifiedBy
    ELSE
      UPDATE  [dbo].[sysprop]
      SET     [objValue] = @list
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID

    INSERT INTO #validTable
    SELECT  'After',* 
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objProperty] = @objProperty
    AND     [objID] = @objID
  END

  SELECT  *
  FROM    #validTable
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
  AND     [objProperty] = @objProperty
  ORDER BY [type] DESC
  DROP TABLE #temp
END
ELSE
BEGIN
  SELECT  [codeType],
          [code],
          [description],
          [comments]
  FROM    [COMPASS].[dbo].[syscode]
  WHERE   [codeType] = @objAction
  ORDER BY CONVERT(INTEGER,SUBSTRING([code],3,5))
END
DROP TABLE #validTable
DROP TABLE #propTable
GO