GO
DECLARE @appCode varchar(20) = 'CLM',
        @objAction varchar(100) = 'ClaimAdjustmentRequest',
        @objID varchar(100) = 'joliver@alliantnational.com',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
DECLARE @propTable TABLE (objProperty varchar(100),objValue varchar(100))
INSERT INTO @propTable (objProperty,objValue) VALUES ('LossAutoLimit','0')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LossReserveLimit','0')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LAEAutoLimit','0')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LAEReserveLimit','0')

DELETE FROM [sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objID] = @objID

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

IF (@objID <> '')
BEGIN
  SELECT 
      RowNum = ROW_NUMBER() OVER(ORDER BY objProperty)
      ,*
  INTO #temp
  FROM @propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @objProperty varchar(100),
          @objValue varchar(100),
          @objName varchar(200)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objProperty=[objProperty],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter
    SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID

    IF (@objValue != '0' AND @objName IS NOT NULL)
    BEGIN
      EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy
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
  AND     [objID] = @objID
  DROP TABLE #temp
END
ELSE
BEGIN
  SELECT  DISTINCT [objID],[objName]
  FROM    [sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
END
DROP TABLE #validTable

GO