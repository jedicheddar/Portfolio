GO
DECLARE @appCode varchar(20) = 'AP',
        @objAction varchar(100) = 'SendEmail',
        @objProperty varchar(100) = 'PayableInvoice',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count int = 0,
        @domain varchar(200) = '@alliantnational.com'

DECLARE @propTable TABLE (objectID varchar(100),objValue varchar(100))
INSERT INTO @propTable (objectID,objValue) VALUES ('' + @domain,'TRUE')

USE [COMPASS]

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY objectID)
    ,*
INTO #temp
FROM @propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @objID varchar(100),@objValue varchar(100),@objName varchar(200) = NULL

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @objID=[objectID],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter
  SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID

  IF (@objID != 'objectID' AND @objValue != 'objValue' AND @objName IS NOT NULL)
  BEGIN

    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy
    
  END
  SET @Iter = @Iter + 1
END

DROP TABLE #temp

SELECT * 
FROM   [dbo].[sysprop]
WHERE  [appCode] = @appCode
AND    [objAction] = @objAction
AND    [objProperty] = @objProperty
ORDER BY objID


GO