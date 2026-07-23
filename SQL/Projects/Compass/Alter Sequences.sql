DECLARE @alter BIT = 0,
        @modifySyskey BIT = 0

DECLARE @sql NVARCHAR(MAX) = '',
        @tempSQL NVARCHAR(MAX),
        @name VARCHAR(50),
        @table VARCHAR(50),
        @column VARCHAR(50),
        @dateColumn VARCHAR(50),
        @seed INTEGER,
        @maxRow INTEGER,
        @index INTEGER

SET NOCOUNT ON;

CREATE TABLE #seq ([name] VARCHAR(50), [table] VARCHAR(50), [column] VARCHAR(50), [dateColumn] VARCHAR(50))
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('affiliation','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('agentActivity','','activityID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('agentFile','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('agentfileform','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('agentmanager','','managerID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('agentPerson','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('alert','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('apInvoice','apinv','apinvID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('apTransaction','aptrx','aptrxID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('ardeposit','','depositID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('arInvoice','arinv','arinvID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('armisc','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('arPmt','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('artran','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('arTransaction','artrx','artrxID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('auditAction','action','actionID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('auditBestPractice','qarbp','bpID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('auditFinding','qarfinding','findingID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('comcode','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('comLog','','logID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('form','iform','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('fulfillment','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('interaction','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('invoiceID','artran','artranID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('job','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('ledgerID','ledger','ledgerID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('log','syslog','','createdate')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('objective','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('organization','','orgID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('orgrole','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('person','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('personRole','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('qualification','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('qualReq','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('rateAttr','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('rateCard','','cardID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('rateRule','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('ratescenario','','scenarioID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('rateState','','cardsetID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('rateTable','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('review','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sentiment','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('stateReqQual','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('StateRequirement','','requirementID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysdest','','destID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysfavorite','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysNote','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysNotification','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysqueue','','queueID','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('sysuserconfig','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('tag','','','')
--INSERT INTO #seq ([name], [table], [column], [dateColumn]) VALUES ('task','','','')

SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY [name]),*
INTO    #temp
FROM    #seq

SET @maxRow = (SELECT MAX([RowNum]) FROM #temp)
SET @index = (SELECT MIN([RowNum]) FROM #temp)

WHILE @index <= @maxRow
BEGIN
  SELECT  @name = [name],
          @table = CASE WHEN [table] = '' THEN [name] ELSE [table] END,
          @column = CASE WHEN [column] = '' THEN [name] + 'ID' ELSE [column] END,
          @dateColumn = [dateColumn]
  FROM    #temp
  WHERE   [RowNum] = @index

  IF (@name <> '')
  BEGIN
    SET @seed = 0
    IF (@dateColumn = '')
      SET @tempSQL = 'SELECT @seed = ISNULL(MAX(CONVERT(INTEGER, [' + @column + '])) + 1, 0) FROM [' + @table + ']'
    ELSE
      SET @tempSQL = 'SELECT TOP 1 @seed = ISNULL(CONVERT(INTEGER, [' + @column + ']) + 1, 0) FROM [' + @table + '] ORDER BY [' + @dateColumn + '] DESC'
    EXECUTE sp_executesql @tempSQL, N'@seed INT OUTPUT', @seed=@seed output

    IF (@modifySyskey = 1)
      SET @sql = @sql + 'UPDATE [syskey] SET [seq] = ' + CONVERT(VARCHAR, @seed) + ' WHERE [type] = ''' + @name + '''' + CHAR(10)
    ELSE
      SET @sql = @sql + 'ALTER SEQUENCE [dbo].[seq_' + @name + '] RESTART WITH ' + CONVERT(VARCHAR, @seed) + ' CYCLE' + CHAR(10)
  END

  SET @index = @index + 1
END

DROP TABLE #temp
DROP TABLE #seq

IF (@modifySyskey = 1)
BEGIN
  SET @sql = @sql + 'UPDATE [syskey] SET [seq] = ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING([agentID], 3, 4)) + 1 FROM [agent])) + ' WHERE [type] = ''agent''' + CHAR(10)
                  + 'UPDATE [syskey] SET [seq] = ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING([attorneyID], 3, 4)) + 1 FROM [attorney])) + ' WHERE [type] = ''attorney''' + CHAR(10)
                  + 'UPDATE [syskey] SET [seq] = ' + CONVERT(VARCHAR, (SELECT MAX([policyID]) + 1 FROM [policy] WHERE [policyID] < 9999)) + ' WHERE [type] = ''policyHoldOpen''' + CHAR(10)
                  + 'UPDATE [syskey] SET [seq] = ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING(CONVERT(VARCHAR, [claimID]), 5, 4)) + 1 FROM [claim])) + ' WHERE [type] = ''claim''' + CHAR(10)
END
ELSE
BEGIN
  SET @sql = @sql + 'ALTER SEQUENCE [dbo].[seq_agent] RESTART WITH ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING([agentID], 3, 4)) + 1 FROM [agent])) + ' CYCLE MINVALUE 1 MAXVALUE 9999' + CHAR(10)
                  + 'ALTER SEQUENCE [dbo].[seq_attorney] RESTART WITH ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING([attorneyID], 3, 4)) + 1 FROM [attorney])) + ' CYCLE MINVALUE 1 MAXVALUE 9999' + CHAR(10)
                  + 'ALTER SEQUENCE [dbo].[seq_policyHoldOpen] RESTART WITH ' + CONVERT(VARCHAR, (SELECT MAX([policyID]) + 1 FROM [policy] WHERE [policyID] < 9999)) + ' CYCLE MINVALUE 1000 MAXVALUE 9000' + CHAR(10)
                  + 'ALTER SEQUENCE [dbo].[seq_claim] RESTART WITH ' + CONVERT(VARCHAR, (SELECT MAX(SUBSTRING(CONVERT(VARCHAR, [claimID]), 3, 4)) + 1 FROM [claim])) + ' CYCLE MINVALUE 1 MAXVALUE 9999' + CHAR(10)
END

IF (@modifySyskey = 1)
BEGIN
  SELECT  'Before',
          [type],
          [seq]
  FROM    [syskey]
  ORDER BY [type]
END
ELSE
BEGIN
  SELECT  'Before',
          [name],
          [current_value],
          [modify_date] 
  FROM    [sys].[sequences]
  ORDER BY [name]
END

IF (@alter = 1)
BEGIN
  EXEC (@sql) 

  IF (@modifySyskey = 1)
  BEGIN
    SELECT  'After',
            [type],
            [seq]
    FROM    [syskey]
    ORDER BY [type]
  END
  ELSE
  BEGIN
    SELECT  'After',
            [name],
            [current_value],
            [modify_date] 
    FROM    [sys].[sequences]
    ORDER BY [name]
  END
END
ELSE
BEGIN
  PRINT @sql
END