USE [COMPASS]
GO
DECLARE @appCode varchar(20) = '',
        @objAction varchar(100) = '',
        @objProperty varchar(100) = '',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count int = 0


DECLARE @propTable TABLE (objectID varchar(100),objValue varchar(100))
INSERT INTO @propTable (objectID,objValue) VALUES ('objectID','objValue')

SELECT * INTO #badTable FROM @propTable WHERE 1=2
SELECT * INTO #goodTable FROM [sysprop] WHERE 1=2

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY objectID)
    ,*
INTO #temp
FROM @propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @objID varchar(100),
        @objValue varchar(100),
        @objName varchar(200)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @objID=[objectID],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

  IF (@objID != 'objectID' AND @objValue != 'objValue')
  BEGIN
    SELECT  @count=COUNT(*)
    FROM    [sysprop]
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objProperty] = @objProperty
    AND     [objID] = @objID

    IF (@count = 1)
    BEGIN
      UPDATE  [sysprop]
      SET     [objValue] = @objValue
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID

      INSERT INTO #goodTable
      SELECT @objID, @objValue
    END
    ELSE
    BEGIN
      INSERT INTO #badTable
      SELECT @objID, @objValue
    END
  END
  SET @Iter = @Iter + 1
END

SELECT * FROM #goodTable
SELECT * FROM #badTable

DROP TABLE #temp

GO