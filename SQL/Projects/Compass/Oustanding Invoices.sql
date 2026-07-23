USE [COMPASS]

DECLARE @month INTEGER = 0,
        @year INTEGER = 0

IF (@month = 0)
  SET @month = MONTH(DATEADD(m,-1,GETDATE()))
  
IF (@year = 0)
  SET @year = YEAR(DATEADD(m,-1,GETDATE()))

SELECT  inv.[apinvID],
        inv.[vendorID],
        inv.[vendorName],
        inv.[stat] AS 'invoiceStatus',
        inv.[amount] AS 'invoiceAmount',
        app.[amount] AS 'approvalAmount',
        app.[dateActed],
        app.[stat] AS 'approvalStatus'
FROM    [dbo].[apinv] inv INNER JOIN
        [dbo].[apinva] app
ON      inv.[apinvID] = app.[apinvID] INNER JOIN
        [dbo].[period] per
ON      per.periodMonth = MONTH(app.[dateActed])
AND     per.periodYear = YEAR(app.[dateActed])
WHERE   per.periodMonth = @month
AND     per.periodYear = @year
AND     app.[stat] = 'P'
ORDER BY inv.[apinvID]