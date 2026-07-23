USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'OPS',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([action] VARCHAR(100), [property] VARCHAR(100), [id] varchar(100), [objValue] varchar(100))
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Reporting','Reinsurance','Limit','750000')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('BatchForm','ZipCode','State','LA')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('DIPStatus','DIPStatus','0','MultiCounty')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('DIPStatus','DIPStatus','1','Best Evidence')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('DIPStatus','DIPStatus','2','Out of County')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','N','New')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','P','Processing')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','R','Reviewing')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','C','Complete')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','NA','N/A - Before "Active"')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','NR','Not Remitted')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Batch','Status','N/A','N/A - After "Active"')


DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] != 'Configuration'

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
        @objAction VARCHAR(100),
        @objProperty VARCHAR(100),
        @objName VARCHAR(100)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @objAction=[action],@objProperty=[property],@objID=[id],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

  SET @objName = ''
  IF (@objValue = '')
  BEGIN
    SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID
    SET @objValue = @objName
  END

  EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objName=@objName, @modifiedBy=@modifiedBy

  SET @Iter = @Iter + 1
END

SELECT  [appCode],
        [objAction],
        [objProperty],
        [objID],
        [objValue],
        [objName],
        [objDesc],
        [objRef],
        [lastModified],
        [modifiedBy],
        [comments]
FROM    [COMPASS].[dbo].[sysprop]
WHERE   [appCode] = @appCode
ORDER BY [appCode], [objAction],[objProperty],[objID]

DROP TABLE #temp
DROP TABLE #propTable

GO