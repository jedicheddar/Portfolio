GO

DECLARE @ID INT = 0,
        @agentID VARCHAR(30) = '',
        @fileNumber VARCHAR(100) = ''

DECLARE @IDStr varchar(max) = '',
        @ImportStr varchar(max) = ''
CREATE TABLE #tpsTable ([ID] INT)
CREATE TABLE #validTable ([tbl] VARCHAR(30), [id] VARCHAR(MAX), [cnt] INT, [insCode] VARCHAR(MAX), [sqlCode] VARCHAR(MAX),[delCode] VARCHAR(MAX))

IF (@ID > 0)
BEGIN
  INSERT INTO #tpsTable ([ID])
  SELECT [agentFileID] FROM [dbo].[agentfile] WHERE [agentFileID] = @ID
END
ELSE
BEGIN
  IF (@agentID <> '' AND @fileNumber <> '')
  BEGIN
    INSERT INTO #tpsTable ([ID])
    SELECT [agentFileID] FROM [dbo].[agentfile] WHERE [agentID] = @agentID AND [fileNumber] = @fileNumber
  END
END

SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY ID),
        *
INTO    #temp
FROM    #tpsTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX([RowNum]) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN([RowNum]) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @ID=[ID] FROM #temp WHERE [RowNum] = @Iter
  IF @IDStr <> ''
  BEGIN
    SET @IDStr = @IDStr + ','
    SET @ImportStr = @ImportStr + ','
  END
  SET @IDStr = @IDStr + CONVERT(VARCHAR,@ID)
  SET @ImportStr = @ImportStr + '''' + CONVERT(VARCHAR,@ID) + ''''
  SET @Iter = @Iter + 1
END
DROP TABLE #temp

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'agentfile' AS [tbl]
        FROM   [dbo].[agentfile]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'job' AS [tbl]
        FROM   [dbo].[job]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'fileproperty' AS [tbl]
        FROM   [dbo].[fileproperty]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'deed' AS [tbl]
        FROM   [dbo].[deed]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'fileparty' AS [tbl]
        FROM   [dbo].[fileparty]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'filecontent' AS [tbl]
        FROM   [dbo].[filecontent]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'filetask' AS [tbl]
        FROM   [dbo].[filetask]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'filefield' AS [tbl]
        FROM   [dbo].[filefield]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [agentFileID] IN (' + @IDStr + ')' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'fileinv' AS [tbl]
        FROM   [dbo].[fileinv]
        WHERE  [agentFileID] in (SELECT [ID] FROM #tpsTable)
        ) a

INSERT INTO #validTable ([tbl], [id], [cnt], [insCode], [sqlCode], [delCode])
SELECT  [tbl],
        CASE WHEN cnt > 0 THEN ID ELSE '' END,
			  [cnt],
        CASE WHEN [cnt] > 0 THEN 'INSERT INTO [' + tbl + '] SELECT * FROM [' + DB_NAME() + '].[dbo].[' + tbl + '] WHERE [fileInvID] IN (SELECT [fileInvID] FROM [dbo].[fileinv] f WHERE [agentFileID] IN (' + @IDStr + '))' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'SELECT * FROM [' + tbl + '] WHERE [fileInvID] IN (SELECT [fileInvID] FROM [dbo].[fileinv] f WHERE [agentFileID] IN (' + @IDStr + '))' ELSE '' END,
        CASE WHEN [cnt] > 0 THEN 'DELETE FROM [' + tbl + '] WHERE [fileInvID] IN (SELECT [fileInvID] FROM [dbo].[fileinv] f WHERE [agentFileID] IN (' + @IDStr + '))' ELSE '' END
FROM    (
        SELECT COUNT(*) AS [cnt],
               @IDStr AS [ID],
               'fileinvitem' AS [tbl]
        FROM   [dbo].[fileinvitem]
        WHERE  [fileInvID] in (SELECT [fileInvID] FROM [dbo].[fileinv] f INNER JOIN #tpsTable t ON f.[agentFileID] = t.[ID])
        ) a

SELECT [tbl], [id], [cnt], [sqlCode], [delCode], [insCode] FROM #validTable ORDER BY [id] DESC

DROP TABLE #tpsTable
DROP TABLE #validTable
GO