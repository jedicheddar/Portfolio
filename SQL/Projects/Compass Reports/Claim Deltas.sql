USE [COMPASS]
GO

DECLARE @startDate DATETIME = '',
        @endDate DATETIME = '',
        @claimID INTEGER = 20172336

CREATE TABLE #deltaTable
(
claimID INTEGER,
refCategory VARCHAR(100),
fromDate DATETIME,
toDate DATETIME,
type VARCHAR(100),
amount DECIMAL(18,2)
)

CREATE TABLE #balanceTable
(
claimID INT,
refCategory VARCHAR(10),
asOfDate DATETIME,
pendingInvoiceAmount DECIMAL(18,2),
approvedInvoiceAmount  DECIMAL(18,2),
completedInvoiceAmount  DECIMAL(18,2),
pendingReserveAmount  DECIMAL(18,2),
approvedReserveAmount DECIMAL(18,2),
reserveBalance DECIMAL(18,2)
)

-- Decide the dates
IF (@startDate IS NULL OR @startDate = '')
  SET @startDate = '2005-01-01'

IF (@endDate IS NULL OR @endDate = '')
  SET @endDate = DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,GETDATE())+1,0))
  
-- Insert statements for procedure here
IF (@claimID = 0)
BEGIN
  INSERT INTO #balanceTable
  EXEC [dbo].[spReportClaimBalances] @asOfDate = @endDate

  INSERT INTO #balanceTable
  EXEC [dbo].[spReportClaimBalances] @asOfDate = @startDate
END
ELSE
BEGIN
  INSERT INTO #balanceTable
  EXEC [dbo].[spReportClaimBalances] @asOfDate = @endDate, @claimID = @claimID

  INSERT INTO #balanceTable
  EXEC [dbo].[spReportClaimBalances] @asOfDate = @startDate, @claimID = @claimID
END

-- Get the deltas of the completed payables
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'pendingPayments' AS 'type',
        curr.[pendingInvoiceAmount] - prev.[pendingInvoiceAmount] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

-- Get the deltas of the completed payables
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'approvedPayments' AS 'type',
        curr.[approvedInvoiceAmount] - prev.[approvedInvoiceAmount] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

-- Get the deltas of the completed payables
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'completePayments' AS 'type',
        curr.[completedInvoiceAmount] - prev.[completedInvoiceAmount] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

-- Get the deltas of the approved adjustments
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'approvedAdjustments' AS 'type',
        curr.[pendingReserveAmount] - prev.[pendingReserveAmount] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

-- Get the deltas of the approved adjustments
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'approvedAdjustments' AS 'type',
        curr.[approvedReserveAmount] - prev.[approvedReserveAmount] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

-- Get the deltas of the approved adjustments
INSERT INTO #deltaTable
SELECT  curr.[claimID],
        curr.[refCategory],
        prev.[asOfDate] AS 'fromDate',
        curr.[asOfDate] AS 'toDate',
        'reserveBalance' AS 'type',
        curr.[reserveBalance] - prev.[reserveBalance] AS 'amount'
FROM    #balanceTable curr INNER JOIN
        #balanceTable prev
ON      prev.[refCategory] = curr.[refCategory]
AND     prev.[claimID] = curr.[claimID]
WHERE   prev.[asOfDate] = @startDate
AND     curr.[asOfDate] = @endDate

SELECT  *
FROM    #deltaTable

DROP TABLE #deltaTable
DROP TABLE #balanceTable