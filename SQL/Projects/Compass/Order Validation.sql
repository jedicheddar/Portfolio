GO

DECLARE @ID VARCHAR(30) = '',
        @admin VARCHAR(100) = '',
        @IDStr nvarchar(max)

DECLARE @orderTable TABLE (ID VARCHAR(30))
DECLARE @validTable TABLE (tbl varchar(30),id varchar(max),cnt int,sqlCode varchar(max),delCode varchar(max))

IF (@ID <> '')
BEGIN
  INSERT INTO @orderTable (ID) VALUES (@ID)
  SET @IDStr = CONVERT(VARCHAR,@ID)
END
ELSE
BEGIN
  INSERT INTO @orderTable (ID)
  SELECT  [orderID]
  FROM    [order]
  GROUP BY [orderID]

  IF (@admin <> '')
    DELETE FROM @orderTable WHERE [ID] IN (SELECT [orderID] FROM [order] WHERE [uid] = @admin)

  SELECT  @IDStr = COALESCE(@IDStr + ',','') + CONVERT(VARCHAR,[ID])
  FROM    @orderTable
END

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'order' AS tbl
        FROM  [dbo].[order]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'ordernote' AS tbl
        FROM  [dbo].[ordernote]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'ordercode' AS tbl
        FROM  [dbo].[ordercode]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'orderproperty' AS tbl
        FROM  [dbo].[orderproperty]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'orderperson' AS tbl
        FROM  [dbo].[orderperson]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

INSERT INTO @validTable (tbl, id, cnt, sqlCode,delCode)
SELECT  tbl
       ,CASE WHEN cnt > 0 THEN ID ELSE '' END
			 ,cnt
       ,CASE WHEN cnt > 0 THEN 'SELECT * FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
       ,CASE WHEN cnt > 0 THEN 'DELETE FROM [dbo].[' + tbl + '] WHERE [orderID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS cnt
              ,@IDStr AS ID
              ,'ordertask' AS tbl
        FROM  [dbo].[ordertask]
        WHERE [orderID] in (SELECT [ID] FROM @orderTable)
        ) a

SELECT * FROM @validTable ORDER BY id DESC, tbl ASC
GO