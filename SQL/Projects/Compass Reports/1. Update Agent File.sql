GO

DECLARE @update BIT = 0,
        @reset BIT = 0

DECLARE @cplCount INT = 0,
        @policyCount INT = 0,
        @hoiCount INT = 0,
        @batchCount INT = 0,
        @sql NVARCHAR(MAX) = ''

IF @reset = 1
BEGIN
  UPDATE [dbo].[cpl] SET [fileID] = NULL
  UPDATE [dbo].[policy] SET [fileID] = NULL
  UPDATE [dbo].[policyhoi] SET [fileID] = NULL
  UPDATE [dbo].[batchform] SET [fileID] = NULL
  DELETE FROM [dbo].[agentfile]
  DELETE FROM [dbo].[sysnote] WHERE [entity] = 'AF'
  UPDATE [dbo].[syskey] SET [seq] = 0, [changedate] = GETDATE() WHERE [type] = 'agentfile'
  UPDATE [dbo].[syskey] SET [seq] = 0, [changedate] = GETDATE() WHERE [type] = 'sysnote'
  --validation
  SELECT COUNT(*) FROM [dbo].[cpl] WHERE [fileID] IS NOT NULL
  SELECT COUNT(*) FROM [dbo].[policy] WHERE [fileID] IS NOT NULL
  SELECT COUNT(*) FROM [dbo].[policyhoi] WHERE [fileID] IS NOT NULL
  SELECT COUNT(*) FROM [dbo].[batchform] WHERE [fileID] IS NOT NULL 
  SELECT COUNT(*) FROM [dbo].[agentfile]
  SELECT COUNT(*) FROM [dbo].[sysnote] WHERE [entity] = 'AF'
END

--Get the counts of each table
SELECT @cplCount=COUNT(*) FROM [dbo].[cpl] WHERE ([fileID] = '' OR [fileID] IS NULL) AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
SELECT @policyCount=COUNT(*) FROM [dbo].[policy] WHERE ([fileID] = '' OR [fileID] IS NULL) AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
SELECT @hoiCount=COUNT(*) FROM [dbo].[policyhoi] WHERE ([fileID] = '' OR [fileID] IS NULL) AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
SELECT @batchCount=COUNT(*) FROM [dbo].[batchform] WHERE ([fileID] = '' OR [fileID] IS NULL) AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)

--Show the counts or the reason why
IF (@cplCount = 0 AND @policyCount = 0 AND @hoiCount = 0 AND @batchCount = 0)
BEGIN
  SELECT 'CPL' AS [table], '' AS [stage], COUNT(*) FROM [dbo].[cpl] WHERE ([fileID] = '' OR [fileID] IS NULL) AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
  UNION ALL
  SELECT 'POLICY', '', COUNT(*) FROM [dbo].[policy] WHERE [fileID] = '' OR [fileID] IS NULL AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
  UNION ALL
  SELECT 'POLICYHOI', '', COUNT(*) FROM [dbo].[policyhoi] WHERE [fileID] = '' OR [fileID] IS NULL AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
  UNION ALL
  SELECT 'BATCHFORM', '', COUNT(*) FROM [dbo].[batchform] WHERE [fileID] = '' OR [fileID] IS NULL AND ([fileNumber] <> '' AND [fileNumber] IS NOT NULL)
  UNION ALL
  SELECT 'AGENTFILE', [stage], COUNT(*) FROM [dbo].[agentfile] GROUP BY [stage]
  ORDER BY [table]
END
ELSE
BEGIN 
  IF (@cplCount > 0)
    SET @sql = @sql + 'SELECT ''CPL'' AS [table], [fileNumber], [fileID], MIN([issueDate]) AS [min], MAX([issueDate]) AS [max], COUNT(*) AS [count] FROM [dbo].[cpl] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) AND [agentID] IS NOT NULL GROUP BY [fileNumber], [fileID]'
  IF (@policyCount > 0 AND @sql <> '') SET @sql = @sql + ' UNION ALL '
  IF (@policyCount > 0)
    SET @sql = @sql + 'SELECT ''POLICY'' AS [table], [fileNumber], [fileID], MIN([issueDate]), MAX([issueDate]), COUNT(*) AS [count] FROM [dbo].[policy] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) AND [agentID] IS NOT NULL GROUP BY [fileNumber], [fileID]'
  IF (@hoiCount > 0 AND @sql <> '') SET @sql = @sql + ' UNION ALL '
  IF (@hoiCount > 0)
    SET @sql = @sql + 'SELECT ''POLICYHOI'' AS [table], [fileNumber], [fileID], MIN([policyDate]), MAX([policyDate]), COUNT(*) AS [count] FROM [dbo].[policyhoi] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) GROUP BY [fileNumber], [fileID]'
  IF (@batchCount > 0 AND @sql <> '') SET @sql = @sql + ' UNION ALL '
  IF (@batchCount > 0)
    SET @sql = @sql + 'SELECT ''BATCHFORM'' AS [table], [fileNumber], [fileID], MIN(b.[createDate]), MAX(b.[createDate]), COUNT(*) AS [count] FROM [dbo].[batch] b INNER JOIN [dbo].[batchform] bf ON b.[batchID] = bf.[batchID] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) GROUP BY [fileNumber], [fileID]'
END
IF (@sql <> '')
  EXECUTE sp_executesql @sql

IF @update = 1
BEGIN
  EXEC [dbo].[spUpdateFileIDCPL]
  EXEC [dbo].[spUpdateFileIDPolicy]
  EXEC [dbo].[spUpdateFileIDBatchForm]
  --Output
  SET @sql = @sql + 'SELECT ''CPL'' AS [table], [fileNumber], COUNT(*) AS [count] FROM [dbo].[cpl] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) AND [agentID] IS NOT NULL GROUP BY [fileNumber]'
  SET @sql = @sql + ' UNION ALL '
  SET @sql = @sql + 'SELECT ''POLICY'' AS [table], [fileNumber], COUNT(*) AS [count] FROM [dbo].[policy] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) AND [agentID] IS NOT NULL GROUP BY [fileNumber]'
  SET @sql = @sql + ' UNION ALL '
  SET @sql = @sql + 'SELECT ''POLICYHOI'' AS [table], [fileNumber], COUNT(*) AS [count] FROM [dbo].[policyhoi] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) GROUP BY [fileNumber]'
  SET @sql = @sql + ' UNION ALL '
  SET @sql = @sql + 'SELECT ''BATCHFORM'' AS [table], [fileNumber], COUNT(*) AS [count] FROM [dbo].[batch] b INNER JOIN [dbo].[batchform] bf ON b.[batchID] = bf.[batchID] WHERE ([fileID] = '''' OR [fileID] IS NULL) AND ([fileNumber] <> '''' OR [fileNumber] IS NOT NULL) GROUP BY [fileNumber]'
  EXECUTE sp_executesql @sql
END

GO