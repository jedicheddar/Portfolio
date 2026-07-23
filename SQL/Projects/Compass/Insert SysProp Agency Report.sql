USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(30) = 'AgencyReport',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([property] VARCHAR(100), [id] varchar(100), [objValue] varchar(100))
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','B','Batch Rcvd')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','C','CPL Issued')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','NPR','NPR Actual')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','NPP','NPR Plan')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','NP%','')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY [id])
    ,*
INTO #temp
FROM #propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @objValue VARCHAR(100),
        @objID VARCHAR(100),
        @objProperty VARCHAR(100),
        @objName VARCHAR(100)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @objProperty=[property],@objID=[id],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

  SET @objName = ''
  IF (@objValue = '')
  BEGIN
    SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID
    SET @objValue = @objName
  END

  EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy

  INSERT INTO #validTable
  SELECT  * 
  FROM    [dbo].[sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
  AND     [objProperty] = @objProperty
  AND     [objID] = @objID

  SET @Iter = @Iter + 1
END
SELECT  *
FROM    #validTable
WHERE   [appCode] = @appCode
ORDER BY [appCode], [objAction],[objProperty],[objID]

DROP TABLE #temp
DROP TABLE #validTable
DROP TABLE #propTable

GO