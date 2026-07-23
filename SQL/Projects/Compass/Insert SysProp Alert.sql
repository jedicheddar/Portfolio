USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'Alert',
        @objProperty varchar(100) = 'Threshold',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @update BIT = 0
        
CREATE TABLE #alertTable ([id] varchar(20), [threshhold] VARCHAR(100), [owner] VARCHAR(100), [type] VARCHAR(100), [response] VARCHAR(100), [description] VARCHAR(100), [datatype] VARCHAR(100))
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('AP01','User Defined','A','1,0','Yes','Accounts Receivable Amount','money')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('AP02','2000,1000','A','1,0','Yes','Debit Balance Amount','money')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('CLM01','0.20,0.15','A','1,0','Yes','Claims Actual Costs Over Net Premium','percent')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('CLM02','0.25,0.20','A','1,0','No','Claims Reserves Over Net Premium','percent')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('OPS01','0.15,0.10','A','1,0','No','CPL Volume Percent Drop','percent')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('OPS02','60,45','A','1,1','No','Days Since Last Policy Remittance','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('OPS03','90,60','A','1,0','Yes','Average Policy Lag Days (Report Gap)','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('OPS04','3,2','A','1,0','No','Three Month Average Policy Unremitted Count','decimal')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('QAR01','390,369','QA','1,1','Yes','Days Since Last QAR','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('QAR02','7,6','A','0,0','Yes','ERR Score','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('QAR03','2,1','R','1,0','Yes','ERR Score Difference','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('QAR04','121,111','A','0,0','Yes','QAR Score','integer')
INSERT INTO #alertTable ([id], [threshhold], [owner], [type], [response], [description], [datatype]) VALUES ('QAR05','9,5','R','1,0','Yes','QAR Score Difference','integer')

IF (@update = 1)
BEGIN
  DELETE FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty
  DELETE FROM [dbo].[syscode] WHERE [codeType] = @objAction

  SELECT 
      RowNum = ROW_NUMBER() OVER(ORDER BY [id])
      ,*
  INTO #temp
  FROM #alertTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @threshhold VARCHAR(100),
          @owner VARCHAR(100),
          @type VARCHAR(100),
          @response VARCHAR(100),
          @code VARCHAR(100),
          @description VARCHAR(100),
          @datatype VARCHAR(100),
          @count INTEGER = 0

  WHILE @Iter <= @MaxRownum
  BEGIN
    --The property
    SELECT @code=[id],@threshhold=[threshhold],@owner=[owner],@type=[type],@response=[response],@description=[description],@datatype=[datatype] FROM #temp WHERE RowNum = @Iter
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objProperty=@objProperty, @objID=@code, @objValue=@threshhold, @objName=@owner, @objDesc=@type, @objRef=@response, @modifiedBy=@modifiedBy

    --The code
    SELECT @count=COUNT(0) FROM [dbo].[syscode] WHERE [codeType] = @objAction AND [code] = @code
    IF (@count = 0)
    BEGIN
      INSERT INTO [dbo].[syscode] ([codeType],[code],[description],[type]) 
      SELECT @objAction,[id],[description],[datatype] FROM #temp WHERE RowNum = @Iter
    END
    ELSE
    BEGIN
      SELECT @code=[id],@threshhold=[threshhold],@owner=[owner],@type=[type],@response=[response] FROM #temp WHERE RowNum = @Iter

      UPDATE  [dbo].[syscode]
      SET     [description] = @description,
              [type] = @datatype
      WHERE   [codeType] = @objAction
      AND     [code] = @code
    END

    SET @Iter = @Iter + 1
  END
  DROP TABLE #temp  
END
SELECT  prop.[appCode],
        code.[description],
        prop.[objProperty],
        prop.[objID],
        prop.[objValue],
        prop.[objName],
        prop.[objDesc],
        prop.[objRef],
        code.[type]
FROM    [dbo].[sysprop] prop INNER JOIN
        [dbo].[syscode] code
ON      prop.[objID] = code.[code]
AND     prop.[appCode] = @appCode
AND     prop.[objAction] = @objAction
AND     prop.[objProperty] = @objProperty
DROP TABLE #alertTable

GO