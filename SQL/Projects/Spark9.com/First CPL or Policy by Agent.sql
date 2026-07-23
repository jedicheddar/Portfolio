SELECT  c.[agency] AS 'Agent Office',
        MIN(icl.[ICLDate]) AS 'First CPL Issue Date',
        MIN(p.[paiddate]) AS 'First Policy Issue Date',
        c.[cintid] AS 'Agent ID'
FROM    [dbo].[t_company] c LEFT OUTER JOIN
        (
        SELECT  [cid],
                MIN([paiddate]) AS 'paiddate'
        FROM    [dbo].[t_policies]
        GROUP BY [cid]
        ) p
ON      c.[cid] = p.[cid] LEFT OUTER JOIN
        (
        SELECT  [EscrowID],
                MIN([ICLDate]) AS 'ICLDate'
        FROM    [dbo].[t_ICL]
        GROUP BY [EscrowID]
        ) icl
ON      c.[cid] = icl.[EscrowID]
GROUP BY c.[agency],
         c.[cintid]
ORDER BY c.[agency]