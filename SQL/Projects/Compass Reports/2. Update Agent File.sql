USE [COMPASS]

DECLARE @update BIT = 0

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;
SET ANSI_WARNINGS OFF;

DECLARE @agentID VARCHAR(20),
        @fileNumber VARCHAR(1000),
        @addr1 VARCHAR(100) = '',
        @addr2 VARCHAR(100) = '',
        @addr3 VARCHAR(100) = '',
        @addr4 VARCHAR(100) = '',
        @city VARCHAR(100) = '',
        @countyID VARCHAR(50) = '',
        @state VARCHAR(2) = '',
        @zip VARCHAR(20) = '',
        @stage VARCHAR(20),
        @transactionType VARCHAR(20) = '',
        @insuredType VARCHAR(20) = '',
        @reportingDate DATETIME = NULL,
        @liability DECIMAL(18,2) = 0,
        @notes VARCHAR(MAX),
        @agentFileID INTEGER

-- Insert statements for procedure here
CREATE TABLE #fileID
(
  [table] VARCHAR(50),
  [agentID] VARCHAR(20),
  [fileNumber] VARCHAR(1000),
	[addr1] VARCHAR(100) NULL,
	[addr2] VARCHAR(100) NULL,
	[addr3] VARCHAR(100) NULL,
	[addr4] VARCHAR(100) NULL,
	[city] VARCHAR(50) NULL,
  [county] VARCHAR(50) NULL,
	[state] VARCHAR(20) NULL,
	[zip] VARCHAR(20) NULL,
  [insuredType] VARCHAR(50),
  [transactionType] VARCHAR(50),
  [revenueType] VARCHAR(50),
  [reportingDate] DATETIME,
  [stage] VARCHAR(50),
  [notes] VARCHAR(MAX)
)

INSERT INTO #fileID ([table],[agentID],[fileNumber],[addr1],[addr2],[addr3],[addr4],[city],[county],[state],[zip],[insuredType],[transactionType],[revenueType],[reportingDate],[stage],[notes])
SELECT  'CPL',
        [agentID],
        [fileNumber],
        [addr1],
        [addr2],
        [addr3],
        [addr4],
        [city],
        [county],
        [state],
        [zip],
        '' AS [insuredType],
        '' AS [transactionType],
        '' AS [revenueType],
        NULL AS [reportingDate],
        'CPLIssued' AS [stage],
        'DataFix:CPLIssued,ARC,Processed Agent File when CPL ' + CONVERT(VARCHAR,[cplID]) + ' is issued' AS [notes]
FROM    [dbo].[cpl]
WHERE   [fileID] NOT IN (SELECT [fileID] FROM [agentfile])
UNION ALL
SELECT  'BATCHFORM',
        b.[agentID],
        bf.[fileNumber],
        '' AS [addr1],
        '' AS [addr2],
        '' AS [addr3],
        '' AS [addr4],
        '' AS [city],
        '' AS [county],
        '' AS [state],
        '' AS [zip],
        bf.[insuredType],
        CASE WHEN bf.[residential] = 1 THEN 'Residential' ELSE 'Commercial' END AS [transactionType],
        ISNULL((SELECT [revenueType] FROM [dbo].[stateform] WHERE [stateID] = b.[stateID] AND [formID] = bf.[formID]),'') AS [revenueType],
        CASE WHEN b.[stat] = 'C' THEN b.[invoiceDate] ELSE NULL END AS [reportingDate],
        CASE WHEN b.[stat] = 'C' THEN 'batchInvoice' ELSE 'batchFormCreate' END AS [stage],
        CASE WHEN b.[stat] = 'C' THEN 'DataFix:batchInvoice,OPS,Processed Agent File when Batch: ' + CONVERT(VARCHAR,b.[batchID]) + ' is completed.' ELSE 'DataFix:batchFormCreate,OPS,Processed Agent File when batchform created with form ID ' + bf.[formID] + ' for policy ID ' + CONVERT(VARCHAR,bf.policyID) + ' and batch ' + CONVERT(VARCHAR,b.[batchID]) END AS [notes]
FROM    [dbo].[batch] b INNER JOIN
        [dbo].[batchform] bf
ON      b.[batchID] = bf.[batchID]
WHERE   [fileID] NOT IN (SELECT [fileID] FROM [agentfile])

IF (@update = 1)
BEGIN
  --Insert into agentfile and sysnote for CPL table
  DECLARE cur CURSOR LOCAL FOR
  SELECT  [agentID],
          [fileNumber],
          [addr1],
          [addr2],
          [addr3],
          [addr4],
          [city],
          [county],
          [state],
          [zip],
          [transactionType],
          [revenueType],
          [reportingDate],
          [stage],
          [notes]
  FROM    #fileID f

  OPEN cur
  FETCH NEXT FROM cur INTO @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @transactionType, @insuredType, @reportingDate, @stage, @notes
  WHILE @@FETCH_STATUS = 0 
  BEGIN
    SET @agentFileID = 0
    EXEC [dbo].[spInsertAgentFile] @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @stage, @transactionType, @insuredType, @reportingDate, @liability, @notes, @agentFileID OUTPUT
    EXEC [dbo].[spInsertSysNote] 'AF', @agentFileID, @notes
    FETCH NEXT FROM cur INTO @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @transactionType, @insuredType, @reportingDate, @stage, @notes
  END
  CLOSE cur
  DEALLOCATE cur

  --Insert into agentfile and sysnote for BATCHFORM
  DECLARE cur CURSOR LOCAL FOR
  SELECT  [agentID],
          [fileNumber],
          [addr1],
          [addr2],
          [addr3],
          [addr4],
          [city],
          [county],
          [state],
          [zip],
          [transactionType],
          [revenueType],
          [reportingDate],
          [stage],
          [notes]
  FROM    #fileID

  OPEN cur
  FETCH NEXT FROM cur INTO @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @transactionType, @insuredType, @reportingDate, @stage, @notes
  WHILE @@FETCH_STATUS = 0 
  BEGIN
    SET @agentFileID = 0
    EXEC [dbo].[spInsertAgentFile] @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @stage, @transactionType ,@insuredType, @reportingDate, @liability, @notes, @agentFileID OUTPUT
    EXEC [dbo].[spInsertSysNote] 'AF', @agentFileID, @notes
    FETCH NEXT FROM cur INTO @agentID, @fileNumber, @addr1, @addr2, @addr3, @addr4, @city, @countyID, @state, @zip, @transactionType, @insuredType, @reportingDate, @stage, @notes
  END
  CLOSE cur
  DEALLOCATE cur
END
ELSE
BEGIN
  SELECT [table], COUNT(*) FROM #fileID GROUP BY [table]
END

DROP TABLE #fileID