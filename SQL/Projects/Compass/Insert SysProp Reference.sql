GO
DECLARE @objAction VARCHAR(100) = 'Reference',
        @objID VARCHAR(100) = 'CanEdit',
        @modifiedBy VARCHAR(100) = 'joliver@alliantnational.com',
        @count INT = 0

DECLARE @propTable TABLE ([appCode] VARCHAR(30),[screen] VARCHAR(30),[value] BIT)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','AgentAppReasonCodeCodes',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','AlertCodes',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','County',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','Period',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','State',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('AMD','Region',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('APM','Agent',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('APM','County',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('APM','Period',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('APM','State',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('CLM','Agent',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('CLM','County',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('CLM','Period',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('CLM','State',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('OPS','Agent',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('OPS','County',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('OPS','Period',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('OPS','State',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('QAM','Agent',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('QAM','County',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('QAM','Period',1)
INSERT INTO @propTable ([appCode],[screen],[value]) VALUES ('QAM','State',1)

USE [COMPASS]
DELETE
FROM   [dbo].[sysprop]
WHERE  [objAction] = @objAction
AND    [objID] = @objID

SELECT RowNum = ROW_NUMBER() OVER(ORDER BY [appCode],[screen]),* INTO #temp FROM @propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @appCode VARCHAR(30),
        @screen VARCHAR(30),
        @value VARCHAR(5)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @appCode=[appCode],@screen=[screen],@value=CASE WHEN [value]=0 THEN 'FALSE' ELSE 'TRUE' END FROM #temp WHERE RowNum = @Iter

  IF (@appCode != '' AND @screen != '')
  BEGIN
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@screen, @objValue=@value, @modifiedBy=@modifiedBy
  END
  SET @Iter = @Iter + 1
END

SELECT * 
FROM   [dbo].[sysprop]
WHERE  [objAction] = @objAction
AND    [objID] = @objID
ORDER BY objID

DROP TABLE #temp

GO