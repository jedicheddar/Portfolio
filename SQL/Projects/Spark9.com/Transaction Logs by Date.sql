--USE [dev_alliant]
--USE [alliant_test]
USE [alliant]
GO

DECLARE @startDate DATETIME = NULL,
        @endDate DATETIME = NULL,
        @service VARCHAR(100) = ''

IF @startDate IS NULL
  SET @startDate = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0))

IF @endDate IS NULL
  SET @endDate = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1))

SELECT  t.[TransactionLogID],
        t.[TimeStamp],
        t.[TransactionServiceType],
        t.[CompanyID],
        t.[CPLNumber],
        t.[PolicyNumber],
        t.[GFNumber],
        t.[Actor],
        t.[UserID]
FROM    [dbo].[TransactionLog] t
WHERE   t.[TransactionTimeStamp] BETWEEN @startDate AND @endDate
AND     t.[TransactionServiceType] LIKE '%' + @service + '%'
ORDER BY [TimeStamp] DESC


