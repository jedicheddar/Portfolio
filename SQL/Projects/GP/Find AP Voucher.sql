USE [ANTIC]
GO

DECLARE @VoucherNum VARCHAR(20) = '',
        @DocNum VARCHAR(20) = ''

SELECT  'Archive' AS [Table],* 
FROM    [ANTIC].[dbo].[cstbAPImportArchive]
WHERE   [VoucherNum] = @VoucherNum
OR      [DocNum] = @DocNum
UNION
SELECT  'Import',* 
FROM    [ANTIC].[dbo].[cstbAPImport]
WHERE   [VoucherNum] = @VoucherNum
OR      [DocNum] = @DocNum