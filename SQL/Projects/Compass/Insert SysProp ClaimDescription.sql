USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'CLM',
        @objAction varchar(100) = 'ClaimDescription',
        @objProperty varchar(100) = '',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0,
        @delete bit = 0
        
CREATE TABLE #propTable ([id] varchar(20), [objValue] varchar(1000), [objDesc] varchar(100))
INSERT INTO #propTable ([id], [objValue], [objDesc]) VALUES ('id','value','')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

IF (@objProperty != '')
BEGIN
  SELECT 
      RowNum = ROW_NUMBER() OVER(ORDER BY [id])
      ,*
  INTO #temp
  FROM #propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @objValue varchar(1000),
          @objID varchar(100),
          @objDesc varchar(100)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objID=[id],@objValue=[objValue],@objDesc=[objDesc] FROM #temp WHERE RowNum = @Iter

    IF (@objValue != 'value' OR @objID != 'id')
    BEGIN
      SELECT @count=COUNT(*) FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty AND [objID] = @objID

      IF (@count = 0) -- New item
        EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objDesc=@objDesc, @modifiedBy=@modifiedBy
      ELSE
      BEGIN
        UPDATE  [dbo].[sysprop]
        SET     [objValue] = @objValue,
                [objDesc] = @objDesc
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        AND     [objID] = @objID

        IF (@delete = 1)
          DELETE  [dbo].[sysprop]
          WHERE   [appCode] = @appCode
          AND     [objAction] = @objAction
          AND     [objProperty] = @objProperty
          AND     [objID] = @objID
      END

      INSERT INTO #validTable
      SELECT  * 
      FROM    [dbo].[sysprop]
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID
    END
    SET @Iter = @Iter + 1
  END
  SELECT  *
  FROM    #validTable
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
  AND     [objProperty] = @objProperty
  DROP TABLE #temp
END
ELSE
BEGIN
  SELECT  DISTINCT [objProperty]
  FROM    [sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
END
DROP TABLE #validTable
DROP TABLE #propTable

GO