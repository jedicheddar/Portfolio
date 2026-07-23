USE [ANTIC]

SELECT  'Archive' AS [Table],* 
FROM    [dbo].[cstbAPImportArchive]
WHERE   [Status] LIKE '%ERROR%'
AND     [BatchID] LIKE '%' + CONVERT(VARCHAR,YEAR(GETDATE())) + '%'
UNION
SELECT  'Import',* 
FROM    [dbo].[cstbAPImport]
WHERE   [Status] LIKE '%ERROR%'
AND     [BatchID] LIKE '%' + CONVERT(VARCHAR,YEAR(GETDATE())) + '%'
ORDER BY [VoucherNum] DESC