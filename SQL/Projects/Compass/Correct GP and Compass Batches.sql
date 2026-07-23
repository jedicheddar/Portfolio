GO
DECLARE @oldFile VARCHAR(50) = '3335027',
        @newFile VARCHAR(50) = '33335027',
        @policyIDGP VARCHAR(30) = '2048350',
        @agentID VARCHAR(10) = '097216',
        @batchID INT = 20120512

DECLARE @spaces INTEGER = 0,
        @good INTEGER = 0,
        @policyID INTEGER = 0

USE [tempdb]
IF (NOT EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[TABLES] WHERE [TABLE_SCHEMA] = 'dbo' AND [TABLE_NAME] = 'file_correction$'))
BEGIN
  CREATE TABLE [file_correction$]
  (
    [old_file] VARCHAR(50),
    [new_file] VARCHAR(50),
    [policy] VARCHAR(50),
    [agent] VARCHAR(50)
  )
END

IF (@oldFile <> '' AND @newFile <> '' AND @policyIDGP <> '' AND @agentID <> '')
BEGIN
  SELECT @newFile = UPPER(@newFile)
  DELETE FROM [tempdb].[dbo].[file_correction$]
  INSERT INTO [tempdb].[dbo].[file_correction$] ([old_file],[new_file],[policy],[agent]) VALUES (@oldFile,@newFile,@policyIDGP,@agentID)
END

SELECT @good=COUNT(*) FROM [tempdb].[dbo].[file_correction$]
IF (@good = 0)
BEGIN
  IF (@oldFile <> '')
    SELECT  'COMPASS-BatchForm' AS [table],bf.[fileNumber],@newFile AS [newFile],CONVERT(VARCHAR,bf.[policyID]) AS [policyID],b.[agentID],b.[batchID],CASE WHEN bf.[fileNumber] = @newFile THEN 'True' ELSE '' END AS [changed]
    FROM    [COMPASS_LIVE].[dbo].[batchform] bf INNER JOIN
            [COMPASS_LIVE].[dbo].[batch] b
    ON      bf.[batchID] = b.[batchID]
    WHERE   [fileNumber] = @oldFile
    UNION
    SELECT  'COMPASS-Policy',[fileNumber],@newFile,CONVERT(VARCHAR,[policyID]),[agentID],0,CASE WHEN [fileNumber] = @newFile THEN 'True' ELSE '' END
    FROM    [COMPASS_LIVE].[dbo].[policy]
    WHERE   [fileNumber] = @oldFile
    UNION
    SELECT  'ANTIC',RTRIM([CSTPONBR]),@newFile,RTRIM([SOPNUMBE]),[CUSTNMBR],[BACHNUMB],CASE WHEN [CSTPONBR] = @newFile THEN 'True' ELSE '' END
    FROM    [ANTIC].[dbo].[SOP30200]
    WHERE   [CSTPONBR] = @oldFile
    
  IF (@policyIDGP <> '')
  BEGIN
    --set the policyID to the GP policy ID without the dash
    IF CHARINDEX('-', @policyIDGP) > 0
      SET @policyID = CONVERT(INTEGER, SUBSTRING(@policyIDGP, 1, CHARINDEX('-', @policyIDGP) - 1))
    ELSE
      SET @policyID = CONVERT(INTEGER, @policyIDGP)
            
    SELECT  'COMPASS-BatchForm' AS [table],bf.[fileNumber],@newFile AS [newFile],CONVERT(VARCHAR,bf.[policyID]) AS [policyID],b.[agentID],b.[batchID],CASE WHEN bf.[fileNumber] = @newFile THEN 'True' ELSE '' END AS [changed]
    FROM    [COMPASS_LIVE].[dbo].[batchform] bf INNER JOIN
            [COMPASS_LIVE].[dbo].[batch] b
    ON      bf.[batchID] = b.[batchID]
    WHERE   [policyID] = @policyID
    UNION
    SELECT  'COMPASS-Policy',[fileNumber],@newFile,CONVERT(VARCHAR,[policyID]),[agentID],0,CASE WHEN [fileNumber] = @newFile THEN 'True' ELSE '' END
    FROM    [COMPASS_LIVE].[dbo].[policy]
    WHERE   [policyID] = @policyID
    UNION
    SELECT  'ANTIC',RTRIM([CSTPONBR]),@newFile,RTRIM([SOPNUMBE]),[CUSTNMBR],[BACHNUMB],CASE WHEN [CSTPONBR] = @newFile THEN 'True' ELSE '' END
    FROM    [ANTIC].[dbo].[SOP30200]
    WHERE   [SOPNUMBE] = @policyIDGP
  END

  DROP TABLE [tempdb].[dbo].[file_correction$]
  RETURN
END

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY policy)
    ,*
INTO #temp
FROM [tempdb].[dbo].[file_correction$]

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SET @batchID = 0
  SELECT  @oldFile=[old_file],@newFile=[new_file],@policyIDGP=[policy],@agentID=[agent]
  FROM    #temp
  WHERE   RowNum = @Iter
  
  --set the policyID to the GP policy ID without the dash
  IF CHARINDEX('-', @policyIDGP) > 0
    SET @policyID = CONVERT(INTEGER, SUBSTRING(@policyIDGP, 1, CHARINDEX('-', @policyIDGP) - 1))
  ELSE
    SET @policyID = CONVERT(INTEGER, @policyIDGP)
    
  IF (@batchID = 0)
  BEGIN
    SELECT  @batchID = b.[batchID]
    FROM    [COMPASS_LIVE].[dbo].[batchform] bf INNER JOIN
            [COMPASS_LIVE].[dbo].[batch] b
    ON      bf.[batchID] = b.[batchID]
    WHERE   [fileNumber] = @oldFile
    AND     [policyID] = @policyID
    AND     [agentID] = @agentID

    IF @batchID = 0
      SELECT  @batchID = [BACHNUMB]
      FROM    [ANTIC].[dbo].[SOP30200]
      WHERE   [SOPNUMBE] = @policyIDGP
      AND     [CSTPONBR] = @oldFile
  END

  SELECT  @good = COUNT(*)
  FROM    [ANTIC].[dbo].[SOP30200]
  WHERE   [SOPNUMBE] = @policyIDGP
  AND     [BACHNUMB] = @batchID
  AND     [CSTPONBR] = @oldFile
  
  IF (@good > 0)
  BEGIN
    --validation tables
    CREATE TABLE #validTable (DBName VARCHAR(20), validType VARCHAR(20),TableName VARCHAR(30),Policy VARCHAR(30),FileNumber VARCHAR(30))
    CREATE TABLE #gpTable (seq INTEGER,tbl VARCHAR(30),invCol VARCHAR(30),fileCol VARCHAR(30))

    DECLARE @tbl VARCHAR(30),
            @invCol VARCHAR(30),
            @fileCol VARCHAR(30),
            @seq INTEGER,
            @sql NVARCHAR(max);

    INSERT INTO #gpTable (seq,tbl,invCol,fileCol) VALUES (1,'RM20101','DOCNUMBR','CSPORNBR')
    INSERT INTO #gpTable (seq,tbl,invCol,fileCol) VALUES (2,'RM30101','DOCNUMBR','CSPORNBR')
    INSERT INTO #gpTable (seq,tbl,invCol,fileCol) VALUES (3,'SOP30200','SOPNUMBE','CSTPONBR')
    SELECT @seq = min(seq) from #gpTable

    WHILE @seq IS NOT NULL
    BEGIN
      SELECT @tbl = [tbl], @invCol = [invCol], @fileCol = [fileCol] FROM #gpTable WHERE [seq] = @seq
      SET @sql = N'SELECT ''ANTIC'',''Pre-Validation'',''' + @tbl + ''',[' + @invCol + '],[' + @fileCol + '] FROM ANTIC.dbo.[' + @tbl + '] WHERE [' + @invCol + '] = ''' + @policyIDGP + ''' AND RTRIM([' + @fileCol + ']) = ''' + @oldFile + ''' AND [BACHNUMB] = ''' + CONVERT(VARCHAR,@batchID) + ''''
      INSERT INTO #validTable
      EXEC sp_executesql @sql

      IF (@@ROWCOUNT > 0)
      BEGIN
        --update
        SET @sql = N'UPDATE ANTIC.dbo.[' + @tbl + '] SET [' + @fileCol + '] = ''' + @newFile + ''' WHERE [' + @invCol + '] = ''' + @policyIDGP + ''' AND RTRIM([' + @fileCol + ']) = ''' + @oldFile + ''' AND [BACHNUMB] = ''' + CONVERT(VARCHAR,@batchID) + ''''
        EXEC sp_executesql @sql

        --validation
        SET @sql = N'SELECT ''ANTIC'',''Post-Validation'',''' + @tbl + ''',[' + @invCol + '],[' + @fileCol + '] FROM ANTIC.dbo.[' + @tbl + '] WHERE [' + @invCol + '] = ''' + @policyIDGP + ''' AND RTRIM([' + @fileCol + ']) = ''' + @newFile + ''' AND [BACHNUMB] = ''' + CONVERT(VARCHAR,@batchID) + ''''
        INSERT INTO #validTable
        EXEC sp_executesql @sql
      END

      SELECT @seq = min([seq]) FROM #gpTable WHERE [seq] > @seq
    END

    --update COMPASS batchform
    INSERT INTO #validTable
    SELECT 'COMPASS','Pre-Validation','batchform',[policyID],[fileNumber] FROM [COMPASS_LIVE].[dbo].[batchform] WHERE [policyID] = @policyID AND [fileNumber] = @oldFile AND [batchID] = @batchID

    IF @@ROWCOUNT > 0
    BEGIN
      --update
      UPDATE [COMPASS_LIVE].[dbo].[batchform] SET [fileNumber] = @newFile, [fileID] = [COMPASS_LIVE].[dbo].[NormalizeFileID] (@newFile) WHERE [policyID] = @policyID AND [fileNumber] = @oldFile AND [batchID] = @batchID

      --validation
      INSERT INTO #validTable
      SELECT 'COMPASS','Post-Validation','batchform',[policyID],[fileNumber] FROM [COMPASS_LIVE].[dbo].[batchform] where [policyID] = @policyID AND [fileNumber] = @newFile AND [batchID] = @batchID
    END
  
    INSERT INTO #validTable
    SELECT 'COMPASS','Pre-Validation','policy',[policyID],[fileNumber] FROM [COMPASS_LIVE].[dbo].[policy] WHERE [policyID] = @policyID AND [fileNumber] = @oldFile
  
    --update COMPASS policy
    IF @@ROWCOUNT > 0
    BEGIN
      --update
      UPDATE [COMPASS_LIVE].[dbo].[policy] SET [fileNumber] = @newFile, [fileID] = [COMPASS_LIVE].[dbo].[NormalizeFileID] (@newFile) WHERE [policyID] = @policyID AND [fileNumber] = @oldFile

      --validation
      INSERT INTO #validTable
      SELECT 'COMPASS','Post-Validation','policy',[policyID],[fileNumber] FROM [COMPASS_LIVE].[dbo].[policy] WHERE [policyID] = @policyID AND [fileNumber] = @newFile
    END

    SELECT DISTINCT * FROM #validTable ORDER BY [validType] DESC,[DBName],[TableName]

    DELETE FROM [tempdb].[dbo].[file_correction$] WHERE [old_file] = @oldFile AND [new_file] = @newFile AND [policy] = @policyIDGP AND [agent] = @agentID
  END
  ELSE
  BEGIN
    SELECT  'COMPASS' AS [table],'Not Good' AS [error],b.[batchID],CONVERT(VARCHAR,bf.[policyID]) AS [policyID],[fileNumber],b.[agentID]
    FROM    [COMPASS_LIVE].[dbo].[batchform] bf INNER JOIN
            [COMPASS_LIVE].[dbo].[batch] b
    ON      bf.[batchID] = b.[batchID]
    WHERE   [policyID] = @policyID
    AND     [agentID] = @agentID
    AND     [fileNumber] = @oldFile
    UNION
    SELECT  'ANTIC','Not Good' AS [error],[BACHNUMB],[SOPNUMBE],[CSTPONBR],[CUSTNMBR]
    FROM    [ANTIC].[dbo].[SOP30200]
    WHERE   [SOPNUMBE] = @policyIDGP
    AND     [CSTPONBR] = @oldFile
  END

  SET @Iter = @Iter + 1
END

DROP TABLE #temp
DROP TABLE #validTable
DROP TABLE #gpTable

SELECT @good=COUNT(*) FROM [tempdb].[dbo].[file_correction$]
IF @good = 0
  DROP TABLE [tempdb].[dbo].[file_correction$]