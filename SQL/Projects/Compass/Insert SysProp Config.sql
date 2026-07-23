USE [COMPASS]

GO
DECLARE @objAction VARCHAR(100) = 'Configuration',
        @objProperty VARCHAR(100) = 'Loads',
        @modifiedBy VARCHAR(100) = 'joliver@alliantnational.com',
        @count INT = 0

DECLARE @propTable TABLE ([appCode] VARCHAR(30),[load] VARCHAR(30),[value] BIT)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('AMD','Agents',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('AMD','States',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('AMD','SysCodes',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('AMD','SysProps',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('APM','SysProps',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('OPS','Agents',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('OPS','Periods',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('OPS','States',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('CAM','Agents',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('CAM','Attorneys',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('CAM','SysProps',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('TPS','Agents',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('TPS','Regions',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('TPS','Counties',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('TPS','States',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('TPS','SysProps',1)
INSERT INTO @propTable ([appCode],[load],[value]) VALUES ('CLM','SysProps',1)

DELETE
FROM   [dbo].[sysprop]
WHERE  [objAction] = @objAction
AND    [objProperty] = @objProperty

SELECT RowNum = ROW_NUMBER() OVER(ORDER BY [appCode],[load]),* INTO #temp FROM @propTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @appCode VARCHAR(30),
        @load VARCHAR(30),
        @value VARCHAR(5)

WHILE @Iter <= @MaxRownum
BEGIN

  SELECT @appCode=[appCode],@load=[load],@value=CASE WHEN [value]=0 THEN 'FALSE' ELSE 'TRUE' END FROM #temp WHERE RowNum = @Iter

  IF (@appCode != '' AND @load != '')
  BEGIN
    EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@load, @objProperty=@objProperty, @objValue=@value, @modifiedBy=@modifiedBy
  END
  SET @Iter = @Iter + 1
END

SELECT * 
FROM   [dbo].[sysprop]
WHERE  [objAction] = @objAction
AND    [objProperty] = @objProperty
ORDER BY [appCode],[objID]

DROP TABLE #temp

GO