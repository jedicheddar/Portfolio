GO
DECLARE @appCode varchar(20) = 'QAR',
        @objAction varchar(100) = 'Auditor',
        @objProperty varchar(100) = '',
        @count int = 0,
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'


DECLARE @propTable TABLE (objectID varchar(100))
INSERT INTO @propTable (objectID) VALUES ('bmason@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('eschweitzer@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('mknight@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('rrussell@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('venriquez@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('jcollis@alliantnational.com')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction

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
        @objName varchar(200)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @objID=[objectID] FROM #temp WHERE RowNum = @Iter
  SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID

  IF (@objID != '' AND @objName IS NOT NULL)
  BEGIN
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objName, @objName=@objName, @modifiedBy=@modifiedBy
      
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
DROP TABLE #temp
DROP TABLE #validTable

GO