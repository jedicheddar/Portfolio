USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'CLM',
        @objAction varchar(100) = 'ClaimAdjustmentRequest',
        @objID varchar(100) = 'joliver@alliantnational.com',
        @count int = 0


DECLARE @propTable TABLE (objProperty varchar(100),objValue varchar(100))
INSERT INTO @propTable (objProperty,objValue) VALUES ('LossAutoLimit','')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LossReserveLimit','')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LAEAutoLimit','')
INSERT INTO @propTable (objProperty,objValue) VALUES ('LAEReserveLimit','')

IF (@objID <> '')
BEGIN
  SELECT * INTO #goodTable FROM @propTable WHERE 1=2
  CREATE TABLE #badTable (objProperty varchar(100),objValue varchar(100),currValue varchar(100))
    

  SELECT RowNum = ROW_NUMBER() OVER(ORDER BY objProperty),*
  INTO #temp
  FROM @propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @objProperty varchar(100),
          @objValue varchar(100)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objProperty=[objProperty],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

    IF (@objValue != '')
    BEGIN
      UPDATE  [sysprop]
      SET     [objValue] = @objValue
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID

      INSERT INTO #goodTable
      SELECT @objProperty, @objValue
    END
    ELSE
    BEGIN
      INSERT INTO #badTable
      SELECT  @objProperty, 
              @objValue,
              [objValue]
      FROM    [sysprop]
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID
    END
    SET @Iter = @Iter + 1
  END

  SELECT * FROM #goodTable
  SELECT * FROM #badTable

  DROP TABLE #temp
  DROP TABLE #goodTable
  DROP TABLE #badTable
END
ELSE
BEGIN
  SELECT  DISTINCT [objID],[objName]
  FROM    [sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
END
GO