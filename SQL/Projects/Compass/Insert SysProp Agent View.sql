USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'Main',
        @objProperty varchar(100) = 'View',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @delete bit = 0

DECLARE @count integer = 0
        
CREATE TABLE #propTable ([id] VARCHAR(30), [col] VARCHAR(30), [desc] VARCHAR(100), [type] VARCHAR(100), [cat] VARCHAR(100))
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('BC','Number of Batches','batchID','count','B')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('FC','Number of Files','fileNumber','count','F')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('GP','Gross Premium','grossPremiumDelta','sum','G')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('NP','Net Premium','netPremiumDelta','sum','N')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('PC','Number of Policies','policyID','count','P')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('RG','Report Gap','reportGap','gap','RG')
INSERT INTO #propTable ([id], [desc], [col], [type], [cat]) VALUES ('RP','Retained Premium','retainedPremiumDelta','sum','R')


DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty

IF (@objProperty != '')
BEGIN
  SELECT 
      RowNum = ROW_NUMBER() OVER(ORDER BY [id])
      ,*
  INTO #temp
  FROM #propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @id VARCHAR(100),
          @desc VARCHAR(100),
          @col VARCHAR(100),
          @type VARCHAR(100),
          @cat VARCHAR(100)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @col=[col],@desc=[desc],@type=[type],@id=[id],@cat=[cat] FROM #temp WHERE RowNum = @Iter
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objProperty=@objProperty, @objID=@id, @objValue=@desc, @objName=@col, @objDesc=@type, @objRef=@cat, @modifiedBy=@modifiedBy

    SET @Iter = @Iter + 1
  END
  DROP TABLE #temp

  SELECT  *
  FROM    [dbo].[sysprop]
  WHERE   [appCode] = @appCode 
  AND     [objAction] = @objAction 
  AND     [objProperty] = @objProperty
END
ELSE
BEGIN
  SELECT  DISTINCT [objProperty]
  FROM    [sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
END
DROP TABLE #propTable

GO