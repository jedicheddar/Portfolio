USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AP',
        @objAction varchar(100) = 'SendEmail',
        @objProperty varchar(100) = 'PayableInvoice',
        @count int = 0,
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'


DECLARE @propTable TABLE (objectID varchar(100),objValue varchar(100))
INSERT INTO @propTable (objectID,objValue) VALUES ('','')

SELECT * INTO #goodTable FROM @propTable WHERE 1=2

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

  SELECT @objID=[objectID] + '@alliantnational.com',@objValue=[objValue] FROM #temp WHERE RowNum = @Iter
  SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID

  IF (@objValue != '' AND @objName IS NOT NULL)
  BEGIN
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy

    INSERT INTO #goodTable
    SELECT @objID, @objValue
  END
  SET @Iter = @Iter + 1
END

SELECT * FROM #goodTable
DROP TABLE #temp
DROP TABLE #goodTable

GO