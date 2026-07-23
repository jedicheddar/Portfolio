USE [COMPASS]
GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'AgentNote',
        @objProperty varchar(100) = 'Category',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0
        
DECLARE @propTable TABLE (id int, objValueNew varchar(100),objValueOld varchar(100))
INSERT INTO @propTable (id, objValueNew,objValueOld) VALUES (0, '','replaceValue')
SELECT * INTO #validTable FROM [sysprop] WHERE 1=2

IF (@objProperty != '')
BEGIN
  SELECT 
      RowNum = ROW_NUMBER() OVER(ORDER BY [id])
      ,*
  INTO #temp
  FROM @propTable

  DECLARE @MaxRownum INT
  SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

  DECLARE @Iter INT
  SET @Iter = (SELECT MIN(RowNum) FROM #temp)

  DECLARE @objValueNew varchar(100),
          @objValueOld varchar(100),
          @objID varchar(100)

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objValueNew=[objValueNew],@objValueOld=[objValueOld] FROM #temp WHERE RowNum = @Iter

    IF (@objValueNew = '' OR @objValueNew != 'newValue')
    BEGIN
      IF (@objValueOld = '' OR @objValueOld = 'replaceValue') -- New item
      BEGIN
        SELECT  @objID = MAX([objID]) + 1
        FROM    [dbo].[sysprop]
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValueNew, @modifiedBy=@modifiedBy
      END
      ELSE
      BEGIN
        SELECT  @objID = [objID]
        FROM    [dbo].[sysprop]
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        AND     [objValue] = @objValueOld

        UPDATE  [dbo].[sysprop]
        SET     [objID] = @objID,
                [objValue] = @objValueNew
        WHERE   [appCode] = @appCode
        AND     [objAction] = @objAction
        AND     [objProperty] = @objProperty
        AND     [objValue] = @objValueOld
      END
      INSERT INTO #validTable
      SELECT  * 
      FROM    [dbo].[sysprop]
      WHERE   [appCode] = @appCode
      AND     [objAction] = @objAction
      AND     [objProperty] = @objProperty
      AND     [objValue] = @objValueNew
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

GO