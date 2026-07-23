GO
DECLARE @appCode varchar(20) = 'AMD',
        @objAction varchar(100) = 'Application',
        @objProperty varchar(100) = 'Document',
        @modifiedBy varchar(100) = 'joliver@alliantnational.com',
        @count integer = 0

DELETE FROM [sysprop] WHERE [appCode] = @appCode AND [objAction] = @objAction AND [objProperty] = @objProperty
        
CREATE TABLE #propTable (id varchar(20), objValue varchar(100), link varchar(200), seq integer)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Attorney','Individual Addendum*','https://alliantnational.com/wp-content/uploads/2017/09/Individual-Addendum.docx',2)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Attorney','Application*','https://alliantnational.com/wp-content/uploads/2017/07/Approved-Attorney-Application.docx',1)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Agency Application - Individual Addendum*','https://alliantnational.com/wp-content/uploads/2021/10/AgentIndividual.docx',3)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Agent Application - Entity Addendum','https://alliantnational.com/wp-content/uploads/2021/10/AgentEntity.docx',4)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Agency Application - Escrow Questionnaire','https://alliantnational.com/wp-content/uploads/2021/10/AgentApplication2.docx',2)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Agency Application - Title and Escrow','https://alliantnational.com/wp-content/uploads/2021/10/AgentApplication1.docx',1)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Agency Application - Affiliated Business Addendum','https://alliantnational.com/wp-content/uploads/2021/10/AgentABA.docx',5)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Insurance Coverage*','',6)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Escrow Reconciliations','',7)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Financials','',8)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Resumes','',9)
INSERT INTO #propTable (id, objValue, link, seq) VALUES ('Agent','Other','',10)

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

  DECLARE @objID varchar(100),
          @objValue varchar(100),
          @link varchar(200),
          @seq integer

  WHILE @Iter <= @MaxRownum
  BEGIN

    SELECT @objID=[id], @objValue=[objValue], @link=[link], @seq=[seq] FROM #temp WHERE RowNum = @Iter
    PRINT @objID + ': ' + @objValue + ';' + @link

    IF (@objValue != 'value' OR @objID != 'id' OR @link != 'link')
      EXEC dbo.spInsertProperty @appCode=@appCode, @objAction=@objAction, @objID=@objID, @objProperty=@objProperty, @objValue=@objValue, @modifiedBy=@modifiedBy, @objName=@link, @objDesc=@seq

    SET @Iter = @Iter + 1
  END
  SELECT  *
  FROM    [dbo].[sysprop]
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
DROP TABLE #propTable

GO