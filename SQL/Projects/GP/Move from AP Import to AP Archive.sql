USE [ANTIC]
GO

DECLARE @BatchID VARCHAR(20) = '',
        @VoucherNum VARCHAR(20) = ''

IF (@BatchID <> '' OR @VoucherNum <> '')
BEGIN
  IF (@BatchID <> '')
  BEGIN
    INSERT INTO [dbo].[cstbAPImportArchive]
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
               ,[Comment]
               ,[RowID])
    SELECT TOP 1000 [Status]
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
    WHERE  [BatchID] = @BatchID

    DELETE FROM [ANTIC].[dbo].[cstbAPImport]
    WHERE  [BatchID] = @BatchID

    SELECT TOP 1000 [Status]
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
    WHERE  [BatchID] = @BatchID
  END
  ELSE
  BEGIN
    INSERT INTO [dbo].[cstbAPImportArchive]
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
               ,[Comment]
               ,[RowID])
    SELECT TOP 1000 [Status]
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

    DELETE FROM [ANTIC].[dbo].[cstbAPImport]
    WHERE  [VoucherNum] = @VoucherNum

    SELECT TOP 1000 [Status]
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
  END
END
ELSE
  SELECT TOP 1000 [Status]
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
GO


