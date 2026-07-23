DECLARE @id INT = 3290,
        @setOpen BIT = 0,
        @setApproval BIT = 1

IF (@id <> 0)
BEGIN
  IF (@setApproval = 0 AND @setOpen = 0)
  BEGIN
    DELETE FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[apinva] WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[apinvd] WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[aptrx] WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[sysdoc] WHERE [entityType] = 'Invoice-AP' AND [entityID]  IN (@id)
    DELETE FROM [ANTIC].[dbo].[cstbAPImport] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
    DELETE FROM [ANTIC].[dbo].[cstbAPImportArchive] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
  END

  IF (@setApproval = 1)
  BEGIN
    UPDATE [COMPASS].[dbo].[apinv] SET [stat] = 'A' WHERE [apinvID] IN (@id)
    UPDATE [COMPASS].[dbo].[apinva] SET [stat] = 'A' WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[aptrx] WHERE [apinvID] IN (@id)
    DELETE FROM [ANTIC].[dbo].[cstbAPImport] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
    DELETE FROM [ANTIC].[dbo].[cstbAPImportArchive] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
  END

  IF (@setOpen = 1)
  BEGIN
    UPDATE [COMPASS].[dbo].[apinv] SET [stat] = 'O' WHERE [apinvID] IN (@id)
    UPDATE [COMPASS].[dbo].[apinva] SET [stat] = 'O' WHERE [apinvID] IN (@id)
    DELETE FROM [COMPASS].[dbo].[aptrx] WHERE [apinvID] IN (@id)
    DELETE FROM [ANTIC].[dbo].[cstbAPImport] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
    DELETE FROM [ANTIC].[dbo].[cstbAPImportArchive] WHERE [VoucherNum] = (SELECT  [refCategory] + CONVERT(VARCHAR, [apinvID]) FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id))
  END
END
SELECT * FROM [COMPASS].[dbo].[apinv] WHERE [apinvID] IN (@id)