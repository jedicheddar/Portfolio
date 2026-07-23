GO

DECLARE @ID int = 0, -- Enter the ID if known
        @claimID int = 0,
        @uid varchar(max) = '',
        @Cat varchar(max) = '',
        @IDStr varchar(max) = '',
        @ImportStr varchar(max) = ''
CREATE TABLE #arTable (ID int, Cat varchar(1))
CREATE TABLE #validTable (tbl varchar(30),id varchar(max),cnt int,sqlCode varchar(max),delCode varchar(max))

IF (@ID <> 0)
BEGIN
  INSERT INTO #arTable (ID,Cat)
  SELECT @ID,[refCategory] FROM [dbo].[arinv] WHERE [arinvID] = @ID
END
ELSE
BEGIN
  IF (@claimID > 0)
  BEGIN
    INSERT INTO #arTable (ID,Cat)
    SELECT [arinvID],[refCategory] FROM [dbo].[arinv] WHERE refID = CONVERT(VARCHAR,@claimID)
  END
  ELSE
  BEGIN
    INSERT INTO #arTable (ID,Cat)
    SELECT [arinvID],[refCategory] FROM [dbo].[arinv] WHERE [uid] = CASE WHEN @uid = '' THEN [uid] ELSE @uid END
  END
END

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY ID)
    ,*
INTO #temp
FROM #arTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @ID=[ID],@Cat=[Cat] FROM #temp WHERE RowNum = @Iter
  IF @IDStr <> ''
  BEGIN
    SET @IDStr = @IDStr + ','
    SET @ImportStr = @ImportStr + ','
  END
  SET @IDStr = @IDStr + CONVERT(VARCHAR,@ID)
  SET @ImportStr = @ImportStr + '''' +  @Cat + CONVERT(VARCHAR,@ID) + ''''
  SET @Iter = @Iter + 1
END
DROP TABLE #temp

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [arinvID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [arinvID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'arinv' AS tbl
        FROM  [dbo].arinv
        WHERE arinvID in (SELECT [ID] FROM #arTable)
        ) a

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [arinvID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [arinvID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'artrx' AS tbl
        FROM  [dbo].artrx
        WHERE arinvID in (SELECT [ID] FROM #arTable)
        ) a

INSERT INTO #validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [entityType] = ''Invoice-AR'' AND [entityID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [entityType] = ''Invoice-AR'' AND [entityID]  IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'sysdoc' AS tbl
        FROM  [dbo].sysdoc
        WHERE [entityType] = 'Invoice-AR'
        AND   [entityID] in (SELECT [ID] FROM #arTable)
        ) a

SELECT * FROM #validTable ORDER BY id DESC, tbl ASC
DROP TABLE #validTable
DROP TABLE #arTable
GO