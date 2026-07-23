USE [alliant_test]

DECLARE @agent VARCHAR(10) = ''

SELECT  c.[iclid]
       ,c.[FileNumber]
       ,c.[EscrowID] AS OfficeID
       ,b.[agency] AS Office
       ,b.[cintid]
       ,c.[agent]
       ,c.[GFNumber]
       ,t.[CPLType]
       ,c.[code]
       ,c.[icldate]
       ,c.[StateName]
       ,c.[Status]
       ,c.[StatusChangeDate]
FROM    [dbo].[t_company] b INNER JOIN
        [dbo].[t_icl] c
ON      c.EscrowID = b.cid INNER JOIN
        [dbo].[t_ClosingLetter] t
ON      t.[ClosingLetterID] = c.[ClosingLetterID]
WHERE   b.[cintid] = @agent
AND     c.[code] IS NOT NULL
ORDER BY c.[icldate] DESC
