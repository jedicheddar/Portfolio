USE [COMPASS]
GO
DECLARE @appCode varchar(20) = '',
        @objAction varchar(100) = '',
        @objProperty varchar(100) = '',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0
        
CREATE TABLE #propTable (id varchar(20), objValue varchar(100),objName varchar(100))
INSERT INTO #propTable (id, objValue,objName) VALUES ('id','value','buffer')

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

  DECLARE @objValue varchar(100),
          @objName varchar(100),
          @objID varchar(100),
          @found INT

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objID=[id],@objValue=[objValue],@objName=[objName] FROM #temp WHERE RowNum = @Iter

    IF (@objValue != 'value' OR @objID != 'id')
    BEGIN
      SELECT @found=COUNT(*) FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty AND [objValue] = @objValue AND [objID] = @objID
      IF (@found = 0) -- New item
        EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy
      ELSE
        UPDATE  [dbo].[sysprop]
        SET     [objValue] = @objValue,
                [objName] = @objName
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        AND     [objValue] = @objValue
        AND     [objID] = @objID

      INSERT INTO #validTable
      SELECT  * 
      FROM    [dbo].[sysprop]
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objValue] = @objValue
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