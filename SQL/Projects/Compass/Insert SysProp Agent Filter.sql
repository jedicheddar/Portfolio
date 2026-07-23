USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'AgentFilter',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable (username varchar(100),stateList varchar(500), managerList varchar(500))
INSERT INTO #propTable (username, stateList, managerList) VALUES ('joliver@alliantnational.com','','')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY username)
    ,*
INTO #temp
FROM #propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @objName varchar(200),
        @objID varchar(100),
        @stateList varchar(100),
        @managerList varchar(500)

WHILE @Iter <= @MaxRownum
BEGIN

  SET @objName = NULL
  SELECT @objID=[username], @stateList=[stateList], @managerList=[managerList] FROM #temp WHERE RowNum = @Iter
  SELECT @objName=[name] FROM [dbo].[sysuser] WHERE [uid] = @objID

  IF (@objName IS NOT NULL)
  BEGIN
    DELETE
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objID] = @objID

    IF (@stateList <> '')
      EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty='State', @objValue=@stateList, @objName=@objName, @modifiedBy=@modifiedBy

    IF (@managerList <> '')
      EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty='Manager', @objValue=@managerList, @objName=@objName, @modifiedBy=@modifiedBy
      
    INSERT INTO #validTable
    SELECT  * 
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objID] = @objID
  END
  SET @Iter = @Iter + 1
END
SELECT * FROM #validTable

DROP TABLE #temp
DROP TABLE #propTable
DROP TABLE #validTable

GO