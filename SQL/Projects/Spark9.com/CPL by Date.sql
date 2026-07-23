use alliant_test

declare @back int = 30 -- days back to look

select  c.iclid
       ,c.FileNumber
       ,c.EscrowID as OfficeID
       ,c.agent
       ,b.agency
       ,c.GFNumber
       ,c.code
       ,c.icldate
       ,c.StateName
       ,c.LenderExtra
from    dbo.t_company b inner join
        dbo.t_icl c
     on c.EscrowID = b.cid
where   c.icldate > getdate() - @back
order by c.icldate desc