GO

DECLARE @ID INTEGER = 1, -- Enter the ID if known
        @course VARCHAR(30) = ''

DECLARE @IDStr varchar(max) = ''

CREATE TABLE #eduTable (ID VARCHAR(30))
CREATE TABLE #validTable (tbl VARCHAR(30),id VARCHAR(max),cnt INT,sqlCode VARCHAR(max),delCode VARCHAR(max))

IF (@ID <> 0)
BEGIN
  INSERT INTO #eduTable (ID)
  SELECT [trainingID] FROM [dbo].[training] WHERE [trainingID] = @ID
END

IF (@course <> '')
BEGIN
  INSERT INTO #eduTable (ID)
  SELECT t.[trainingID] FROM [dbo].[training] t INNER JOIN [dbo].[course] c ON t.[courseID] = c.[courseID] WHERE c.[name]  = @course
END

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY ID)
    ,*
INTO #temp
FROM #eduTable

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
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [trainingID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [trainingID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'training' AS tbl
        FROM  [dbo].[person]
        WHERE [personID] in (SELECT [ID] FROM #eduTable)
        ) a

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [courseID] IN (SELECT [courseID] FROM [dbo].[training] WHERE [trainingID] IN (' + @IDStr + '))' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [courseID] IN (SELECT [courseID] FROM [dbo].[training] WHERE [trainingID] IN (' + @IDStr + '))' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'course' AS tbl
        FROM  [dbo].[person]
        WHERE [personID] in (SELECT [ID] FROM #eduTable)
        ) a


SELECT * FROM #validTable ORDER BY id DESC, tbl ASC
DROP TABLE #validTable
DROP TABLE #eduTable
GO