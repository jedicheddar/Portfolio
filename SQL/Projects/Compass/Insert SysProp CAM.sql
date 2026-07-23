USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'CAM',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([action] VARCHAR(100), [property] VARCHAR(100), [id] varchar(100), [objValue] varchar(100))
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','ActionType','C','Corrective')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','ActionType','R','Recommendation')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','ActionType','S','Suggestive')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','CompleteStatus','E','Effective')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','CompleteStatus','M','Moderately Effective with Follow-up')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','CompleteStatus','P','Partially Effective')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','Status','C','Completed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','Status','O','Open')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','Status','P','Planned')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Action','Status','X','Cancelled')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionApproval','Status','A','Approved')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionApproval','Status','D','Denied')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionApproval','Status','S','Sent')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','bjohnson@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','bmason@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','cdunbar@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','cyates@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','dallen@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','dcoffie@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','dhoffman@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','dsinclair@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','fcamperlengo@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','jblack@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','jcollis@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','jhensley@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','jmilligan@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','joliver@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','jstein@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','lyates@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','mknight@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','mpurohit@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','mszenas@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','ndedouh@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','randerson@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','rjones@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','rrussell@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','sflorez@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','shendrickson@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','twebb@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','wmcdonald@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('ActionOwner','','venriquez@alliantnational.com','')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Configuration','Loads','Agents','TRUE')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Configuration','Loads','Attorneys','TRUE')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Configuration','Loads','SysProps','TRUE')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Entity','A','Agent')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Entity','C','Company')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Entity','D','Department')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Entity','T','Attorney')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Severity','1','Minor')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Severity','2','Intermediate')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Severity','3','Major')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Status','A','Active')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Finding','Status','C','Closed')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] <> 'Configuration'

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
        @objAction varchar(30),
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
SELECT  *
FROM    #validTable
WHERE   [appCode] = @appCode
ORDER BY [appCode], [objAction],[objProperty],[objID]

DROP TABLE #temp
DROP TABLE #validTable
DROP TABLE #propTable

GO