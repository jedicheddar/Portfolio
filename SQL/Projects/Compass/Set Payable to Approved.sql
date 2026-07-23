USE [COMPASS]

DECLARE @apinv INTEGER = 0,
        @category VARCHAR(20) = NULL

IF (@apinv > 0)
BEGIN
  SELECT @category=[refCategory]+CONVERT(VARCHAR,[apinvID]) FROM [apinv] WHERE [apinvID] = @apinv

  IF (@category IS NOT NULL)
  BEGIN
    UPDATE [COMPASS].[dbo].[apinv] SET [stat] = 'A' WHERE [apinvID] = @apinv
    DELETE FROM [COMPASS].[dbo].[aptrx] WHERE [apinvID] = @apinv
    DELETE FROM [ANTIC].[dbo].[cstbAPImport] WHERE [VoucherNum] = @category
    DELETE FROM [ANTIC].[dbo].[cstbAPImportArchive] WHERE [VoucherNum] = @category
  END
END