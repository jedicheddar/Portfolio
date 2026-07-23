use alliant_test

declare @id int = 0

select  c.[iclid]
       ,c.[FileNumber]
       ,c.[EscrowID] as OfficeID
       ,b.[agency]
       ,c.[GFNumber]
       ,c.[code]
       ,c.[icldate]
       ,c.[StateName]
       ,c.[Status]
       ,c.[AttorneyID]
       ,c.[Agent]
from      [dbo].[t_company] b inner join
          [dbo].[t_icl] c
     on c.[EscrowID] = b.cid
  where c.[iclid] = @id
  and   c.[code] is not null
