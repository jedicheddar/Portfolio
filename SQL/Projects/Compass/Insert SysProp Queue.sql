USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'SYS',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([action] VARCHAR(100), [property] VARCHAR(100), [id] varchar(100), [objValue] varchar(100))
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Queue','Status','Q','Queued')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Queue','Status','R','Running')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Queue','Status','C','Completed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Queue','Status','F','Failed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Entity','G','Agent')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Type','P','Printed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Type','E','Emailed')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Type','F','File Stored')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','arAgentStatementQuery','Agent Statement')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','invoiceStatementQuery','A/R Invoice')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','arAgingSummaryQuery','A/R Aging Report')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','arFileAgingQuery','A/R File Report')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','cronAgentAppDocument','Agent Application')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Action','cronAsyncBatchform','Batch Form Import')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Email','arAgentStatementQuery','QueueAREmail')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Email','invoiceStatementQuery','QueueAREmail')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('Destination','Subject','arAgingSummaryQuery','A/R Aging Report')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','A','Agency')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','C','Claims')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','E','Executive')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','O','Operations')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','P','Production')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','T','Accounting')
INSERT INTO #propTable ([action], [property], [id], [objValue]) VALUES ('User','Department','U','Underwriting')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND ([objAction] = 'Queue' OR [objAction] = 'Destination')

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