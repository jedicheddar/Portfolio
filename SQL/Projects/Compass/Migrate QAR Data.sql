SET NOCOUNT ON

USE [COMPASS]

CREATE TABLE #nameTable (auditor VARCHAR(100), name VARCHAR(100))INSERT INTO #nameTable (auditor, name) VALUES ('CWinfree','Chuck Winfree')
INSERT INTO #nameTable (auditor, name) VALUES ('Gladys  Orlando','Gladys Orlando')
INSERT INTO #nameTable (auditor, name) VALUES ('Gladys Orlando & Joey Prohaska','Gladys Orlando')
INSERT INTO #nameTable (auditor, name) VALUES ('Gladys Orlando and Scott Florez','Gladys Orlando')
INSERT INTO #nameTable (auditor, name) VALUES ('GOrlando','Gladys Orlando')
INSERT INTO #nameTable (auditor, name) VALUES ('J. Prohaska, G. Orlando, S. Florez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska &  Gladys Orlando','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska &  Virginia Enriquez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Chuck Winfree','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Gladys Orlando','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Mark Knight','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Patricia Davis','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Randy Russell','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Scott Floorez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Scott Flore','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Scott Florez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Tamra Hathcock','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Virginia Enriqu3ez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Virginia Enriquez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska & Vrginia Enriquez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Chuck Winfree','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Galdys Orlando','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Gladys Orlando','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Randy Russell','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Scott Florez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Virginia Enriquez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska and Virginia K. Enriquez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska, Gladys Orlando & Tamra Hathcock','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska, Scott Florez','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prohaska, Scott Florez & Gladys Orlando','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Joey Prrohaska and Randy Russell','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('Paul Rost and Joey Prohaska','Joey Prohaska')
INSERT INTO #nameTable (auditor, name) VALUES ('R Russell','Randy Russell')
INSERT INTO #nameTable (auditor, name) VALUES ('Randy Russell & Scott Florez','Randy Russell')
INSERT INTO #nameTable (auditor, name) VALUES ('Randy Russell, Scott Florez','Randy Russell')
INSERT INTO #nameTable (auditor, name) VALUES ('Rany Russell','Randy Russell')
INSERT INTO #nameTable (auditor, name) VALUES ('RRussell','Randy Russell')
INSERT INTO #nameTable (auditor, name) VALUES ('Scot Florez','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez & Gladys Orlando','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez & Joey Prohaska','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez & Randy Russell','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez & Virgina Enriquez','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez & Virginia Enriquez','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez (TB & TH)','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez and Joey Prohaska','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez and Randy Russell','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez and Virginia Enriquez','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Scott Florez/Gladys Orlando','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('Sflorez','Scott Florez')
INSERT INTO #nameTable (auditor, name) VALUES ('THathcock','Tamra Hathcock')
INSERT INTO #nameTable (auditor, name) VALUES ('TPC, LLC - Patricia Davis','Patricia Davis')
INSERT INTO #nameTable (auditor, name) VALUES ('TPC, LLC/Patricia Davis','Patricia Davis')
INSERT INTO #nameTable (auditor, name) VALUES ('TPC, LLC/Patricia/Alliant/Tamra','Patricia Davis')
INSERT INTO #nameTable (auditor, name) VALUES ('V Enriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('V K Enriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('V K Enriquez & Randy Russell','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('VEnriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('Virgini  K. Enriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('Virginia Enriquez & Joey Prohaska','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('Virginia Enriquez and Gladys Orlando','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('Virginia K.  Enriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('Virginia K. Enriquez','Virginia Enriquez')
INSERT INTO #nameTable (auditor, name) VALUES ('VK Enriquez','Virginia Enriquez')

CREATE TABLE #auditTable (auditID VARCHAR(25), qarID INT, agentID varchar(20), stateID VARCHAR(2))
CREATE TABLE #entryTable (auditID VARCHAR(25), qarID INT, agentID varchar(20), auditAgentID VARCHAR(20), stateID VARCHAR(2))
CREATE TABLE #stateTable (code VARCHAR(02),stateID VARCHAR(2))
INSERT INTO #stateTable (code, stateID)
SELECT RIGHT('00' + CONVERT(VARCHAR,[seq]),2), [stateID] FROM [dbo].[state]

--Insert audits that join to the agent table on ID
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID)
SELECT  a.[auditID],
        SUBSTRING(CONVERT(VARCHAR,YEAR(a.[auditDate])), 3, 2),
        b.[agentID],
        a.[agentID],
        b.[stateID]
FROM    [dbo].[audit] a INNER JOIN
        [dbo].[agent] b
ON      a.[agentID] = b.[agentID]
WHERE   a.[auditID] NOT IN (SELECT [auditID] FROM #entryTable)

--Insert audits that join to the agent table on name
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID)
SELECT  a.[auditID],
        SUBSTRING(CONVERT(VARCHAR,YEAR(a.[auditDate])), 3, 2),
        b.[agentID],
        a.[agentID],
        b.[stateID]
FROM    [dbo].[audit] a INNER JOIN
        [dbo].[agent] b
ON      a.[name] = b.[name]
WHERE   a.[auditID] NOT IN (SELECT [auditID] FROM #entryTable)

--Insert audits that don't join to the agent table on ID or name
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID)
SELECT  a.auditID,
        SUBSTRING(CONVERT(VARCHAR,YEAR(a.[auditDate])), 3, 2),
        b.[code] + CASE SUBSTRING(a.[agentID],3,1) WHEN ' ' THEN SUBSTRING(a.[agentID],4,4) ELSE SUBSTRING(a.[agentID],3,4) END,
        a.agentID,
        b.stateID
FROM    dbo.audit a INNER JOIN
        #stateTable b
ON      b.stateID = substring(a.[agentID],1,2)
WHERE   a.[auditID] NOT IN (SELECT [auditID] FROM #entryTable)

INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20100721-TX2550',10,'432250','TX 2550','TX')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170629-97113',17,'097113','97113','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170626-15100',17,'151000','15100','IA')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170810-97260',17,'097260','97260','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170809-91055',17,'091055','91055','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170823-97302',17,'097302','97302','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170512-61030',17,'061030','61030','CO')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170726-91001',17,'091001','91001','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170816-91060',17,'091060','91060','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170601-06126',17,'067126','06126','CO')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170815-97299',17,'097299','97299','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170531-97202',17,'097202','97202','FL')
INSERT INTO #entryTable (auditID, qarID, agentID, auditAgentID, stateID) VALUES ('20170906-67370',17,'067370','67370','CO')
DELETE FROM #entryTable WHERE [agentID] NOT IN (SELECT [agentID] FROM [agent])

DELETE FROM #auditTable
INSERT INTO #auditTable (auditID, qarID, agentID, stateID)
SELECT  [auditID],
        CONVERT(VARCHAR,MIN([qarID])) + RIGHT(10000 + ROW_NUMBER() OVER (PARTITION BY SUBSTRING(CONVERT(VARCHAR,MIN([qarID])), 1, 2) ORDER BY MIN([qarID])), 4),
        MIN([agentID]),
        [stateID]
FROM    #entryTable
GROUP BY [auditID],[stateID]

SELECT * FROM [dbo].[audit] WHERE [auditID] NOT IN (SELECT [auditID] FROM #auditTable) ORDER BY [name]

----- START TABLE INSERTS -----
DECLARE @rowcount int,
        @valid int

DELETE FROM [dbo].[action]
DELETE FROM [dbo].[actionNote]
DELETE FROM [dbo].[qar]
DELETE FROM [dbo].[qaraction]
DELETE FROM [dbo].[qarbp]
DELETE FROM [dbo].[qarfinding]
DELETE FROM [dbo].[qarnote]
DELETE FROM [dbo].[qarsection]
DELETE FROM [dbo].[finding]
DELETE FROM [dbo].[findingNote]
DELETE FROM [dbo].[qaranswer]
DELETE FROM [dbo].[qarfile]
DELETE FROM [dbo].[qaraccount]

/*******/
/* qar */
/*******/
--/*
INSERT INTO [dbo].[qar]
            ([qarID],
             [version],
             [agentID],
             [auditYear],
             [createDate],
             [schedStartDate],
             [schedFinishDate],
             [auditStartDate],
             [auditFinishDate],
             [score],
             [auditor],
             [uid],
             [contactName],
             [contactPhone],
             [contactFax],
             [contactEmail],
             [deliveredTo],
             [comments],
             [stat],
             [stateID],
             [auditType],
             [errType],
             [refAuditID]
             )
--*/
SELECT  b.[qarID],
        'K' as version,
        b.[agentID],
        YEAR(a.[auditDate]),
        a.[createdate],
        a.[auditDate],
        a.[auditDate],
        a.[auditDate],
        a.[auditDate],
        a.[score],
        a.[auditor],
        ISNULL((SELECT [uid] FROM [sysuser] WHERE [name] = a.[auditor]),(SELECT TOP 1 [uid] FROM [sysuser] s INNER JOIN #nameTable n ON s.[name] = n.[name])),
        a.[contact],
        a.[phone],
        a.[fax],
        a.[email],
        a.[deliveredto],
        a.[comments],
        'C',
        b.stateID,
        (CASE SIGN(a.[score] - 30) WHEN -1 THEN 'E' ELSE 'Q' END),
        '',
        b.[auditID]
FROM    dbo.audit a INNER JOIN
        #auditTable b
ON      a.auditID = b.auditID

SELECT @rowcount = COUNT(*) FROM [dbo].[qar]

IF @rowcount > 0
BEGIN
  PRINT 'Table qar inserted ' + convert(varchar,@rowcount) + ' records.'
END
     
/***********/
/* qarnote */
/***********/
--/*
INSERT INTO [dbo].[qarnote]
            ([qarID],
             [seq],
             [dateCreated],
             [uid],
             [secured],
             [takenBy],
             [stat],
             [comments]
             )
--*/
SELECT  b.[qarID],
        1,
        a.[createdate],
        a.[uid],
        1,
        'Converted',
        'C',
        'Migrated ' + convert(varchar,GETDATE(),20)
FROM    dbo.audit a INNER JOIN
        #auditTable b
ON      a.auditID = b.auditID

SET @rowcount = @@ROWCOUNT

IF @rowcount > 0
BEGIN
  PRINT 'Table qarnote inserted ' + convert(varchar,@rowcount) + ' records.'
END

/**************/
/* qarsection */
/**************/
--/*
INSERT INTO [dbo].[qarsection]
            ([qarID],
             [sectionID],
             [score],
             [comments],
             [weight]
             )
--*/
SELECT  b.[qarID],
        a.[sectionID],
        a.[score],
        a.[comments],
        CASE a.[sectionID]
          WHEN 1 THEN 0.5
          WHEN 2 THEN 2
          WHEN 3 THEN 1
          WHEN 4 THEN 2
          WHEN 5 THEN 3
          WHEN 6 THEN 3
          WHEN 7 THEN 2
          WHEN 8 THEN 1.5
        END AS [weight]
FROM    dbo.auditsection a inner join
        #auditTable b
     ON a.auditID = b.auditID
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[qarsection]

IF @rowcount > 0
BEGIN
  PRINT 'Table qarsection inserted ' + convert(varchar,@rowcount) + ' records.'
END

/*********/
/* qarbp */
/*********/
--/*
INSERT INTO [dbo].[qarbp]
           ([bpID],
            [qarID],
            [sectionID],
            [questionID],
            [description],
            [files],
            [comments]
            )
--*/
SELECT  a.[bpID],
        b.[qarID],
        a.[sectionID],
        a.[questionID],
        a.[description],
        a.[files],
        a.[comments]
FROM    dbo.auditbp a inner join
        #auditTable b
     ON a.auditID = b.auditID
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[qarbp]

IF @rowcount > 0
BEGIN
  PRINT 'Table qarbd inserted ' + convert(varchar,@rowcount) + ' records.'
  SELECT @rowcount=MAX([bpID]) from dbo.qarbp
  UPDATE dbo.syskey SET [seq]=@rowcount+1 WHERE [type]='auditBestPractice'
END

/**************/
/* qarfinding */
/**************/
--/*
INSERT INTO [dbo].[qarfinding]
           ([findingID]
           ,[qarID]
           ,[sectionID]
           ,[questionID]
           ,[description]
           ,[severity]
           ,[files]
           ,[reference]
           ,[comments])
--*/
SELECT  a.[findingID],
        b.[qarID],
        a.[sectionID],
        a.[questionID],
        a.[description],
        a.[severity],
        a.[files],
        a.[reference],
        a.[comments]
FROM    dbo.auditfinding a inner join
        #auditTable b
     ON a.auditID = b.auditID
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[qarfinding]

IF @rowcount > 0
BEGIN
  PRINT 'Table qarfinding inserted ' + convert(varchar,@rowcount) + ' records.'
  SELECT @rowcount=MAX([findingID]) from dbo.qarfinding
  UPDATE dbo.syskey SET [seq]=@rowcount+1 WHERE [type]='auditFinding'
END

/***********/
/* finding */
/***********/
--/*
INSERT INTO [dbo].[finding]
           ([findingID],
            [source],
            [sourceID],
            [description],
            [severity],
            [comments],
            [uid],
            [stat],
            [refType],
            [refID],
            [entity],
            [entityID]
            )
--*/
SELECT  a.[findingID],
        'QAR',
        b.[qarID],
        a.[description],
        a.[severity],
        a.[comments],
        c.[uid],
        'C',
        'A',
        b.[agentID],
        'Agent',
        b.[agentID]
FROM    dbo.auditfinding a inner join
        #auditTable b inner join
        dbo.audit c
     ON c.auditID = b.auditID
     ON b.auditID = a.auditID
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[finding]

IF @rowcount > 0
BEGIN
  PRINT 'Table finding inserted ' + convert(varchar,@rowcount) + ' records.'
END

/***************/
/* findingNote */
/***************/
--/*
INSERT INTO [dbo].[findingNote]
           ([findingID],
            [seq],
            [dateCreated],
            [uid],
            [secured],
            [takenBy],
            [stat],
            [comments]
            )
--*/
SELECT  a.[findingID],
        1,
        c.[createdate],
        c.[uid],
        1,
        'Converted',
        'C',
        'Migrated ' + convert(varchar,GETDATE(),20)
FROM    dbo.auditfinding a inner join
        #auditTable b inner join
        dbo.audit c
     ON c.auditID = b.auditID
     ON b.auditID = a.auditID
     
SELECT @rowcount = COUNT(*) FROM [dbo].[findingNote]

IF @rowcount > 0
BEGIN
  PRINT 'Table findingNote inserted ' + convert(varchar,@rowcount) + ' records.'
END

/*************/
/* qaraction */
/*************/
--/*
INSERT INTO [dbo].[qaraction]
           ([actionID],
            [qarID],
            [findingID],
            [actionType],
            [stat],
            [dueDate],
            [comments]
            )
--*/
SELECT  a.[actionID],
        b.[qarID],
        a.[findingID],
        a.[actionType],
        a.[stat],
        a.[duedate],
        a.[comments]
FROM    dbo.auditaction a inner join
        #auditTable b
     ON a.auditID = b.auditID
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[qaraction]

IF @rowcount > 0
BEGIN
  PRINT 'Table qaraction inserted ' + convert(varchar,@rowcount) + ' records.'
  SELECT @rowcount=MAX([actionID]) from dbo.qaraction
  UPDATE dbo.syskey SET [seq]=@rowcount+1 WHERE [type]='auditAction'
END

/**********/
/* action */
/**********/
--/*
INSERT INTO [dbo].[action]
           ([actionID],
            [findingID],
            [source],
            [sourceID],
            [actionType],
            [uid],
            [dueDate],
            [stat],
            [followupDate],
            [comments]
            )
--*/
SELECT  a.[actionID],
        a.[findingID],
        'QAR',
        b.[qarID],
        a.[actiontype],
        c.[uid],
        a.[duedate],
        CASE a.[stat]
          WHEN 'O' THEN 'P'
          WHEN 'I' THEN 'O'
          WHEN 'R' THEN 'X'
          ELSE 'C'
        END AS [stat],
        a.[followupdate],
        a.[comments]
FROM    dbo.auditaction a inner join
        #auditTable b inner join
        dbo.audit c
     ON c.[auditID] = b.[auditID]
     ON b.[auditID] = a.[auditID]
ORDER BY b.qarID asc

SELECT @rowcount = COUNT(*) FROM [dbo].[action]

IF @rowcount > 0
BEGIN
  PRINT 'Table action inserted ' + convert(varchar,@rowcount) + ' records.'
END

/**************/
/* actionNote */
/**************/
--/*
INSERT INTO [dbo].[actionNote]
           ([actionID],
            [seq],
            [dateCreated],
            [uid],
            [secured],
            [takenBy],
            [stat],
            [comments]
            )
--*/
SELECT  b.[actionID],
        ROW_NUMBER() OVER (PARTITION BY b.[actionID] ORDER BY c.[date] ASC) AS [seq],
        c.[date],
        c.[uid],
        1,
        c.[takenby],
        c.[stat],
        CASE b.[stat]
          WHEN 'O' THEN 'Planned: ' + c.[comments]
          WHEN 'I' THEN 'Opened: ' + c.[comments]
          WHEN 'R' THEN 'Cancelled: ' + c.[comments]
          ELSE 'Completed: ' + c.[comments]
        END AS [stat]
FROM    #auditTable a inner join
        dbo.auditaction b inner join
        (
        SELECT [actionID],
               [notedate] as [date],
               [uid],
               [takenby],
               null AS [stat],
               [comments]
        FROM [dbo].[auditactionnote]
        UNION ALL
        SELECT [actionID],
               [statdate],
               [uid],
               'Converted',
               [stat],
               [comments]
        FROM [dbo].[auditactionstat]
        ) c
     ON c.[actionID] = b.[actionID]
     ON b.[auditID] = a.[auditID]
     
SELECT @rowcount = COUNT(*) FROM [dbo].[actionNote]

IF @rowcount > 0
BEGIN
  PRINT 'Table actionNote inserted ' + convert(varchar,@rowcount) + ' records.'
END

DROP TABLE #entryTable
DROP TABLE #auditTable
DROP TABLE #stateTable
DROP TABLE #nameTable

/* Some Validation */
--Only one audit ID per row
PRINT ''
SELECT  @valid = COUNT(*)
FROM    (
        SELECT  [refAuditID],
                COUNT(*) AS cnt
        FROM    [dbo].[qar]
        GROUP BY [refAuditID]
        HAVING  COUNT(*) > 2
        ) a

PRINT 'One Audit ID per row: ' + CASE @valid WHEN 0 THEN 'TRUE' ELSE 'FALSE' END

IF (@valid > 0)
BEGIN
  SELECT  q.[qarID],q.[refAuditID]
  FROM    [dbo].[qar] q INNER JOIN
          (
          SELECT  [refAuditID],
                  COUNT(*) AS cnt
          FROM    [dbo].[qar]
          GROUP BY [refAuditID]
          HAVING  COUNT(*) > 2
          ) a
  ON      q.[refAuditID] = a.[refAuditID]
END

--All agents match agent table
SELECT  @valid = COUNT(*)
FROM    [dbo].[qar]
WHERE   [agentID] NOT IN (SELECT [agentID] FROM [dbo].[agent])

PRINT 'All agents in agent table: ' + CASE @valid WHEN 0 THEN 'TRUE' ELSE 'FALSE' END

IF (@valid > 0)
BEGIN
  SELECT  [qarID],[agentID]
  FROM    [dbo].[qar]
  WHERE   [agentID] NOT IN (SELECT [agentID] FROM [dbo].[agent])
END

--All uids are filled in
SELECT  @valid = COUNT(*)
FROM    [dbo].[qar]
WHERE   [uid] IS NULL

PRINT 'All UIDs are filled in: ' + CASE @valid WHEN 0 THEN 'TRUE' ELSE 'FALSE' END

IF (@valid > 0)
BEGIN
  SELECT  [qarID],[uid]
  FROM    [dbo].[qar]
  WHERE   [uid] IS NULL
END

--All uid match the sysuser table
SELECT  @valid = COUNT(*)
FROM    [dbo].[qar]
WHERE   [uid] NOT IN (SELECT [uid] FROM [dbo].[sysuser])

PRINT 'All auditors in sysuser table: ' + CASE @valid WHEN 0 THEN 'TRUE' ELSE 'FALSE' END

IF (@valid > 0)
BEGIN
  SELECT  [qarID],[uid]
  FROM    [dbo].[qar]
  WHERE   [uid] NOT IN (SELECT [uid] FROM [dbo].[sysuser])
END
