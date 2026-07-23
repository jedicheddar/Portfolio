USE [ANTIC]

DECLARE @migrate BIT = 0,
        @batchID VARCHAR(100) = '',
        @voucher VARCHAR(100) = ''

SELECT  'Import' AS [Table],*
FROM    [dbo].[cstbAPImport]
UNION ALL
SELECT  'Archive',*
FROM    [dbo].[cstbAPImportArchive]
WHERE   [Status] LIKE '%ERROR%'
AND     [BatchID] = CASE WHEN @batchID = '' THEN [BatchID] ELSE @batchID END
AND     [VoucherNum] = CASE WHEN @voucher = '' THEN [VoucherNum] ELSE @voucher END
ORDER BY [DocDate] DESC

IF (@migrate = 1 AND @batchID <> '')
BEGIN
  INSERT INTO [dbo].[cstbAPImport] ([Status],[BatchID],[VoucherNum],[DocType],[Description],[DocDate],[VendorID],[PONumber],[DocNum],[DocAmount],[Note],[PurchAccount],[PurchAmount],[Comment])
  SELECT  '',
          [BatchID],
          [VoucherNum],
          [DocType],
          [Description],
          [DocDate],
          [VendorID],
          [PONumber],
          [DocNum],
          [DocAmount],
          [Note],
          [PurchAccount],
          [PurchAmount],
          [Comment]
  FROM    [dbo].[cstbAPImportArchive]
  WHERE   [Status] LIKE '%ERROR%'
  AND     [BatchID] = @batchID
  AND     [VoucherNum] = CASE WHEN @voucher = '' THEN [VoucherNum] ELSE @voucher END

  DELETE
  FROM    [dbo].[cstbAPImportArchive]
  WHERE   [Status] LIKE '%ERROR%'
  AND     [BatchID] = @batchID
  AND     [VoucherNum] = CASE WHEN @voucher = '' THEN [VoucherNum] ELSE @voucher END

  SELECT  *
  FROM    [dbo].[cstbAPImport]
END

IF (@batchID <> '')
BEGIN
  SELECT 'C:\PayableImport\Alliant.APImport.Console.exe "Validate" "Polk" "ANTIC" "sa" "cLBynbJ9E57hfqSYzLtyZw==" "C:\PayableImport\Logs\Prod" "ORPHAN_RECORDS.txt" "' + @batchID + '"'
  SELECT 'C:\PayableImport\Alliant.APImport.Console.exe "Import" "Polk" "ANTIC" "sa" "cLBynbJ9E57hfqSYzLtyZw==" "C:\PayableImport\Logs\Prod" "ORPHAN_RECORDS.txt" "' + @batchID + '"'
END