SELECT  *
FROM    [COMPASS].[dbo].[aptrx] ap LEFT OUTER JOIN
        [ANTIC].[dbo].[cstbAPImportArchive] ia
ON      ap.[apinvID] = SUBSTRING(ia.[VoucherNum], 2, 4)
ORDER BY ap.[apinvID]