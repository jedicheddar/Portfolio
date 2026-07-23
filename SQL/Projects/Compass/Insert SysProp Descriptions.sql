USE [COMPASS]
GO
DECLARE @appCode varchar(20) = '',
        @objAction varchar(100) = '',
        @objProperty varchar(100) = '',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @delete bit = 0

DECLARE @count integer = 0
        
CREATE TABLE #propTable ([id] VARCHAR(30), [objValue] VARCHAR(100))
INSERT INTO #propTable ([id], [objValue]) VALUES ('','')

SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

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

  DECLARE @objValue varchar(100),
          @objID varchar(100)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objID=[id],@objValue=[objValue] FROM #temp WHERE RowNum = @Iter

    IF (@objValue != '' OR @objID != '')
    BEGIN
      SELECT @count=COUNT(*) FROM [dbo].[sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty AND [objID] = @objID

      IF (@count = 1 AND @delete = 1)
        DELETE  [dbo].[sysprop]
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        AND     [objID] = @objID

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
  AND     [objProperty] = @objProperty
  DROP TABLE #temp
END
ELSE
BEGIN
  SELECT  DISTINCT [objProperty]
  FROM    [sysprop]
  WHERE   [appCode] = @appCode
  AND     [objAction] = @objAction
END
DROP TABLE #validTable
DROP TABLE #propTable

GO