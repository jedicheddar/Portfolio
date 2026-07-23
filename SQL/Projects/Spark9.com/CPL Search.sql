USE [alliant]

DECLARE @yearTable TABLE (yr INT)
INSERT INTO @yearTable (yr) VALUES (2015)
INSERT INTO @yearTable (yr) VALUES (2016)

SELECT  i.[ICLID] AS 'CPL ID',
        i.[ICLDate] AS 'Date',
        i.[Status] AS 'Status',
        i.[Agent] AS 'User',
        e.[agency] AS 'Office',
        e.[cintid] AS 'Office ID',
        t.[CPLType] AS 'CPL Type',
        l.[lender_comp_name] AS 'Name',
        l.[lender_addr1] AS 'Address',
        l.[lender_city] AS 'City',
        l.[lender_state] AS 'State',
        l.[lender_zip] AS 'Zip Code'
FROM      [dbo].[t_ICL] i INNER JOIN
          [dbo].[t_company] e
     ON i.[escrowID] = e.[cid] INNER JOIN
          [dbo].[BeneficiaryCpl] b
     ON i.[iclid] = b.[CplId] INNER JOIN
          [dbo].[t_lenders] l
     ON b.[BeneficiaryId] = l.[lender_id] INNER JOIN
          [dbo].[t_ClosingLetter] t
     ON i.[ClosingLetterID] = t.[ClosingLetterID]
WHERE   YEAR(i.[ICLDate]) IN (SELECT [yr] FROM @yearTable)
AND    (e.[agency] LIKE '%Williams%' OR
        e.[agency] LIKE '%Foresight%')
AND     l.[BeneficiaryType] = 'Lender'
ORDER BY i.[ICLDate] desc,b.[BeneficiaryCplId] asc