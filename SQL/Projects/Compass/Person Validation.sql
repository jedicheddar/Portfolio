GO

DECLARE @ID VARCHAR(30) = '', -- Enter the ID if known
        @first VARCHAR(30) = '',
        @last VARCHAR(30) = '',
        @email VARCHAR(100) = ''

DECLARE @IDStr varchar(max) = ''

CREATE TABLE #personTable (ID VARCHAR(30))
CREATE TABLE #validTable (tbl VARCHAR(30),id VARCHAR(max),cnt INT,sqlCode VARCHAR(max),delCode VARCHAR(max))

IF (@ID <> 0)
BEGIN
  INSERT INTO #personTable (ID)
  SELECT [personID] FROM [dbo].[person] WHERE [personID] = @ID
END

IF (@first <> '')
BEGIN
  INSERT INTO #personTable (ID)
  SELECT [personID] FROM [dbo].[person] WHERE [firstName] = @first
END

IF (@last <> '')
BEGIN
  INSERT INTO #personTable (ID)
  SELECT [personID] FROM [dbo].[person] WHERE [lastName] = @last
END

IF (@email <> '')
BEGIN
  INSERT INTO #personTable (ID)
  SELECT [personID] FROM [dbo].[personcontact] WHERE [contactID] = @email
END

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY ID)
    ,*
INTO #temp
FROM #personTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @ID=[ID] FROM #temp WHERE RowNum = @Iter
  IF @IDStr <> ''
  BEGIN
    SET @IDStr = @IDStr + ','
  END
  SET @IDStr = @IDStr + CONVERT(VARCHAR,@ID)
  SET @Iter = @Iter + 1
END
DROP TABLE #temp

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'person' AS tbl
        FROM  [dbo].[person]
        WHERE [personID] in (SELECT [ID] FROM #personTable)
        ) a

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'personagent' AS tbl
        FROM  [dbo].[personagent]
        WHERE [personID] in (SELECT [ID] FROM #personTable)
        ) a

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [personID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'personcontact' AS tbl
        FROM  [dbo].[personcontact]
        WHERE [personID] in (SELECT [ID] FROM #personTable)
        ) a

SELECT * FROM #validTable ORDER BY id DESC, tbl ASC
DROP TABLE #validTable
DROP TABLE #personTable
GO