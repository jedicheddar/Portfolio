USE [ANTIC]
GO

DECLARE @VoucherNum VARCHAR(20) = ''

IF (@VoucherNum <> '')
BEGIN
  SELECT 'Archive'
        ,[Status]
        ,[BatchID]
        ,[VoucherNum]
        ,[DocType]
        ,[Description]
        ,[DocDate]
        ,[VendorID]
        ,[PONumber]
        ,[DocNum]
        ,[DocAmount]
        ,[Note]
        ,[PurchAccount]
        ,[PurchAmount]
        ,[Comment]
        ,[RowID]
  FROM   [ANTIC].[dbo].[cstbAPImportArchive]
  WHERE  [VoucherNum] = @VoucherNum

  INSERT INTO [dbo].[cstbAPImport]
             ([Status]
             ,[BatchID]
             ,[VoucherNum]
             ,[DocType]
             ,[Description]
             ,[DocDate]
             ,[VendorID]
             ,[PONumber]
             ,[DocNum]
             ,[DocAmount]
             ,[Note]
             ,[PurchAccount]
             ,[PurchAmount]
             ,[Comment])
  SELECT [Status]
        ,[BatchID]
        ,[VoucherNum]
        ,[DocType]
        ,[Description]
        ,[DocDate]
        ,[VendorID]
        ,[PONumber]
        ,[DocNum]
        ,[DocAmount]
        ,[Note]
        ,[PurchAccount]
        ,[PurchAmount]
        ,[Comment]
  FROM   [ANTIC].[dbo].[cstbAPImportArchive]
  WHERE  [VoucherNum] = @VoucherNum

  DELETE FROM [ANTIC].[dbo].[cstbAPImportArchive]
  WHERE  [VoucherNum] = @VoucherNum

  SELECT 'Import'
        ,[Status]
        ,[BatchID]
        ,[VoucherNum]
        ,[DocType]
        ,[Description]
        ,[DocDate]
        ,[VendorID]
        ,[PONumber]
        ,[DocNum]
        ,[DocAmount]
        ,[Note]
        ,[PurchAccount]
        ,[PurchAmount]
        ,[Comment]
        ,[RowID]
  FROM   [ANTIC].[dbo].[cstbAPImport]
  WHERE  [VoucherNum] = @VoucherNum
END
ELSE
BEGIN
  SELECT  *
  FROM    [ANTIC].[dbo].[cstbAPImportArchive]
  ORDER BY [DocDate] DESC
END
GO


