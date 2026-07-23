USE [ANTIC]

DECLARE @batchID INTEGER = 0,
        @archiveToTest BIT = 0

IF (@batchID > 0)
BEGIN
  IF (@archiveToTest = 0)
  BEGIN
    INSERT INTO [dbo].[cstbInvoiceArchive]
    SELECT * FROM [dbo].[cstbInvoiceImport] WHERE [BatchID] = @batchID

    DELETE FROM [dbo].[cstbInvoiceImport] WHERE [BatchID] = @batchID
  END
  ELSE
  BEGIN
    INSERT INTO [dbo].[cstbInvoiceImport]
    SELECT [Status],[FileName],[BatchID],[Seq],[CurrentDate],[InvoiceDate],[BatchReceivedDate],[CustomerID],[FileID],[TransactionType],[PolicyID],[FormType],[FormID],[FormDescription],[StatCode],[PolicyEffectiveDate],[Liability],[County],[Residential],[GrossPremium],[NetPremium],[RetainedPremium],[GPDocNum],[Comment] FROM [dbo].[cstbInvoiceArchive] WHERE [BatchID] = @batchID

    DELETE FROM [dbo].[cstbInvoiceArchive] WHERE [BatchID] = @batchID
  END
END