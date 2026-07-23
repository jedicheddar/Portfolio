/****** Script for SelectTopNRows command from SSMS  ******/
USE [COMPASS]

DECLARE @year INT = 2021

CREATE TABLE #qar
(
	[qarID] [int] NOT NULL,
  [version] [varchar](20) NULL,
	[createDate] [datetime] NULL,
	[auditYear] [int] NULL,
	[agentID] [varchar](20) NULL,
	[stateID] [varchar](2) NULL,
	[schedStartDate] [datetime] NULL,
	[schedFinishDate] [datetime] NULL,
	[uid] [varchar](100) NULL,
	[auditor] [varchar](100) NULL,
	[auditType] [varchar](1) NULL,
  [errType] [varchar](1) NULL
)

INSERT INTO #qar ([qarID],[version],[createDate],[auditYear],[agentID],[stateID],[uid],[auditor],[schedStartDate],[schedFinishDate],[auditType],[errType])
SELECT  CONVERT(INTEGER, CONVERT(VARCHAR, @year) + RIGHT('0000' + CONVERT(VARCHAR, ROW_NUMBER() OVER (ORDER BY [State], [Agent #])), 4)) AS [qarID],
        'L' AS [version],
        GETDATE() AS [createDate],
        @year AS [auditYear],
        [Agent #] AS [agentID],
        [State] AS [stateID],
        (SELECT [uid] FROM [sysuser] WHERE [name] = [2021 Auditor]) AS [uid],
        [2021 Auditor] AS [auditor],
        CONVERT(DATETIME, [Proposed Audit Date]) AS [schedStartDate],
        CONVERT(DATETIME, [Proposed Audit Date]) AS [schedFinishDate],
        SUBSTRING([Type of Audit], 1, 1) AS [auditType],
        CASE WHEN [Type of Audit] = 'ERR' THEN 'I' ELSE '' END AS [errType]
FROM    [tempdb].[dbo].[qar]
WHERE   YEAR([Proposed Audit Date]) = @year

DECLARE @count INT = 0

SELECT @count=COUNT(*) FROM [qar] WHERE [qarID] IN (SELECT [qarID] FROM #qar)

IF (@count = 0)
BEGIN
  PRINT 'Inserting new audit(s)'
  INSERT INTO [qar] ([qarID],[version],[createDate],[auditYear],[agentID],[stateID],[uid],[auditor],[schedStartDate],[schedFinishDate],[auditType],[errType],[stat],[contactName],[contactPhone],[contactFax],[contactEmail],[deliveredTo],[comments])
  SELECT  [qarID],
          [version],
          [createDate],
          [auditYear],
          [agentID],
          [stateID],
          [uid],
          [auditor],
          [schedStartDate],
          [schedFinishDate],
          [auditType],
          [errType],
          'P' AS [stat],
          '' AS [contactName],
          '' AS [contactPhone],
          '' AS [contactFax],
          '' AS [contactEmail],
          '' AS [deliveredTo],
          '' AS [comments]
  FROM    #qar

  INSERT INTO [qarnote] ([qarID],[seq],[dateCreated],[uid],[secured],[stat],[comments])
  SELECT  [qarID],
          1 AS [seq],
          [createDate],
          [uid],
          1 AS [secured],
          'P' AS [stat],
          'Planned' AS [comments]
  FROM    #qar

  PRINT 'Cancelling Skipped Audits'
  UPDATE  [qar]
  SET     [stat] = 'X',
          [auditFinishDate] = NULL,
          [auditStartDate] = NULL
  FROM    [qar] q INNER JOIN
          #qar q1
  ON      q.[qarID] = q1.[qarID]
  WHERE   q.[schedStartDate] = '2021-01-01'

  INSERT INTO [qarnote] ([qarID],[seq],[dateCreated],[uid],[secured],[stat],[comments])
  SELECT  [qarID],
          2 AS [seq],
          [createDate],
          [uid],
          1 AS [secured],
          'X' AS [stat],
          'Audit is being skipped in 2021 due to low risk evaluation' AS [comments]
  FROM    #qar
  WHERE   [schedStartDate] = '2021-01-01'
END
ELSE
BEGIN
  PRINT 'Deleting ' + CONVERT(VARCHAR, @count) + ' audit(s)'
  DELETE FROM [qar] WHERE [qarID] IN (SELECT [qarID] FROM #qar)
  DELETE FROM [qarnote] WHERE [qarID] IN (SELECT [qarID] FROM #qar)
END

DROP TABLE #qar