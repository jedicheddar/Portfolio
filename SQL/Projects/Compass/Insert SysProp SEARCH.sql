GO
DECLARE @appCode varchar(20) = 'TPS',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([action] VARCHAR(100), [property] VARCHAR(100), [id] varchar(100), [objValue] varchar(100))
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','0','Qualia')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','1','Resware')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','2','SoftPro')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','3','RamQuest')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','4','E-Closing')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('AgentFile','Software','15','Closers'' Choice')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','O','Open')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','P','Processing')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','X','Cancelled')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','R','Rendered')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','F','Fulfilled')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Status','C','Closed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Priority','1','High')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Priority','2','Medium')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Job','Priority','3','Low')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('JobRoute','Status','O','Open')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('JobRoute','Status','C','Closed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Entity','I','Individual')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Entity','C','Corporate')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Clause','VA','and/or the Secretary of Veterans Affairs')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Clause','HUD','and/or the Secretary of Housing and Urban Development')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Clause','ISAOA',', its successors and/or assigns')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Party','Clause','ATIMA',', as their interest may appear')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Product','Type','C','Commitment')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Product','Revenue','I','Income')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Product','Revenue','C','Credit')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','C','Commercial')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','L','Land')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','V','Villa')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','O','Condominium')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','R','Residential')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Property','Type','C','Commercial')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('JobContent','Type','R','Requirement')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('JobContent','Type','E','Exception')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('JobContent','Type','I','Instrument')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Order','Filter','DueDays','14')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode

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

  INSERT INTO #validTable
  SELECT  * 
  FROM    [dbo].[sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
  AND     [objProperty] = @objProperty
  AND     [objID] = @objID

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
FROM    [dbo].[sysprop]
WHERE   [appCode] = @appCode
ORDER BY [appCode],[objAction],[objProperty],[objID]

DROP TABLE #temp
DROP TABLE #validTable
DROP TABLE #propTable

GO