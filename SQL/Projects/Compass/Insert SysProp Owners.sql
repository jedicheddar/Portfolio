USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'CAM',
        @objAction varchar(100) = '',
        @objProperty varchar(100) = 'ActionOwner',
        @count int = 0,
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'


DECLARE @propTable TABLE (objectID varchar(100))
INSERT INTO @propTable (objectID) VALUES ('bmason@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('bgrubb@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('bjohnson@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('dsinclair@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('dcoffie@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('dallen@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('gorlando@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('ghampton@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('gzehner@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('jstein@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('jhensley@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('jprohaska@proescrowandtitle.biz')
INSERT INTO @propTable (objectID) VALUES ('krank@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('lbrasier@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('mpurohit@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('mknight@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('mszenas@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('mrubin@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('ndedouh@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('pmulder@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('rrussell@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('randerson@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('sflorez@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('shendrickson@alliantnational.com')
INSERT INTO @propTable (objectID) VALUES ('twebb@alliantnational.com')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

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
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objID, @objName=@objName, @modifiedBy=@modifiedBy
      
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
DROP TABLE #validTable

GO