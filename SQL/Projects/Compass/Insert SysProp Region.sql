USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'Region',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0
        
CREATE TABLE #propTable ([property] VARCHAR(100), [id] VARCHAR(20), [objValue] VARCHAR(100))
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','SW','Southwest')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','MW','Midwest')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','W','West')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','FL','Florida')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('Category','SE','Southeast')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('States','SW','AR,LA,NM,OK,TX')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('States','MW','KS,MN,MO,IA,NE,WI')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('States','W','AZ,CO,NV,UT')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('States','FL','FL')
INSERT INTO #propTable ([property], [id], [objValue]) VALUES ('States','SE','AL,GA,MS,NC,SC,TN')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

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
        @objProperty VARCHAR(100)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @objProperty=[property],@objID=[id],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

  IF (@objValue != 'value' OR @objID != 'id')
  BEGIN
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @modifiedBy=@modifiedBy

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
ORDER BY [objID],[objProperty]
DROP TABLE #temp
DROP TABLE #validTable
DROP TABLE #propTable

GO