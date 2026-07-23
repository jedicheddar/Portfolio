USE [COMPASS]
GO

DECLARE @claimID INTEGER = 0,
        @startDate DATETIME = '2018-09-01',
        @endDate DATETIME = '2018-12-31'

CREATE TABLE #accountingTable
(
  [claimID] INTEGER,
  [type] VARCHAR(20),
  [refCategory] VARCHAR(100),
  [asOfDate] DATETIME,
  [transDate] DATETIME,
  [pendingAmount] DECIMAL(18,2),
  [approvedAmount] DECIMAL(18,2),
  [completedAmount] DECIMAL(18,2),
  [waivedAmount] DECIMAL(18,2),
  [stat] VARCHAR(20)
)

INSERT INTO #accountingTable ([claimID],[type],[refCategory],[asOfDate],[transDate],[pendingAmount],[approvedAmount],[completedAmount],[stat])
SELECT  CONVERT(INTEGER,[refID]) AS [claimID],
        'Payable' AS [type],
        [refCategory],
        [asOfDate],
        [transDate],
        [pendingAmount],
        [approvedAmount],
        [completedAmount],
        [stat]
FROM    [dbo].[GetInvoiceDetails] (@endDate)
WHERE   [refID] = CONVERT(VARCHAR,@claimID)
AND     [transDate] > @startDate

INSERT INTO #accountingTable ([claimID],[type],[refCategory],[asOfDate],[transDate],[pendingAmount],[approvedAmount],[completedAmount],[stat])
SELECT  [claimID],
        'Reserve' AS [type],
        [refCategory],
        [asOfDate],
        [transDate],
        [pendingAmount] * -1,
        [approvedAmount] * -1,
        [completedAmount] * -1,
        [stat]
FROM    #accountingTable
WHERE   [type] = 'Payable'

INSERT INTO #accountingTable ([claimID],[type],[refCategory],[asOfDate],[transDate],[pendingAmount],[approvedAmount],[completedAmount],[stat])
SELECT  [claimID],
        'Reserve' AS [type],
        [refCategory],
        [asOfDate],
        [transDate],
        [pendingAmount],
        0,
        [approvedAmount],
        [stat]
FROM    [dbo].[GetClaimReserveDetails] (@endDate)
WHERE   [claimID] = @claimID
AND     [transDate] > @startDate

INSERT INTO #accountingTable ([claimID],[type],[asOfDate],[transDate],[pendingAmount],[completedAmount],[waivedAmount],[stat])
SELECT  CONVERT(INTEGER,[refID]) AS [claimID],
        'Receivable' AS [type],
        [asOfDate],
        [transDate],
        [pendingAmount],
        [completedAmount],
        [waivedAmount],
        [stat]
FROM    [dbo].[GetReceivableDetails] (@endDate)
WHERE   [refID] = CONVERT(VARCHAR,@claimID)
AND     [transDate] > @startDate

SELECT  [claimID],
        [type],
        (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'PayableInvoice' AND [objProperty] = 'Category' AND [objID] = [refCategory]) AS [category],
        [transDate],
        [completedAmount] AS [amount]
FROM    #accountingTable ORDER BY [transDate], [type]

DROP TABLE #accountingTable

GO
