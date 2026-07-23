USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'Activity',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0,
        @delete bit = 0
        
CREATE TABLE #propTable ([type] VARCHAR(50), [id] VARCHAR(20), [objValue] VARCHAR(100), [sort] INTEGER)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','N','Net Premium',1)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','G','Gross Premium',2)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','P','Policies',7)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','I','CPLs Issued (Gross)',4)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','X','CPLs Expired',6)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','V','CPLs Voided',5)
INSERT INTO #propTable ([type], [id], [objValue], [sort]) VALUES ('Category','T','CPLs Issued (Net)',3)
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Type','P','Planned')
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Type','A','Actual')
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Type','I','Issued')
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Type','R','Reported')
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Status','O','Open')
INSERT INTO #propTable ([type], [id], [objValue]) VALUES ('Status','C','Closed')

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
        @objSort VARCHAR(10)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @objProperty=[type],@objID=[id],@objValue=[objValue],@objSort=CONVERT(VARCHAR,[sort]) FROM #temp WHERE RowNum = @Iter
  IF (@objSort IS NULL)
    SET @objSort = ''

  SELECT @count=COUNT(*) FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty AND [objID] = @objID
  IF (@count = 0) -- New item
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @objRef=@objSort, @modifiedBy=@modifiedBy
  ELSE
  BEGIN
    UPDATE  [dbo].[sysprop]
    SET     [objValue] = @objValue,
            [objRef] = CASE WHEN @objSort IS NULL THEN [objRef] ELSE @objSort END
    WHERE   [appCode] = @appCode
    AND     [objAction] = @objAction
    AND     [objProperty] = @objProperty
    AND     [objID] = @objID

    IF (@delete = 1)
      DELETE  [dbo].[sysprop]
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objID] = @objID
  END
  SET @Iter = @Iter + 1
END
SELECT  * 
FROM    [dbo].[sysprop]
WHERE   [appCode] = @appCode
AND     [objAction] = @objAction
ORDER BY [objProperty],[objID]

DROP TABLE #temp
DROP TABLE #propTable

GO