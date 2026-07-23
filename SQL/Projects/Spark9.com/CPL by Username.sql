declare @username varchar(200) = ''

select  c.iclid
       ,c.FileNumber
       ,c.EscrowID as OfficeID
       ,b.agency as Office
       ,c.agent
       ,c.GFNumber
       ,t.CPLType
       ,c.code
       ,c.icldate
       ,c.StateName
       ,c.Status
       ,c.StatusChangeDate
from    dbo.t_company b inner join
        dbo.t_icl c
     on c.EscrowID = b.cid inner join
        dbo.t_ClosingLetter t
     on t.ClosingLetterID = c.ClosingLetterID
  where c.agent = @username
  and   c.code is not null
  order by c.icldate desc
