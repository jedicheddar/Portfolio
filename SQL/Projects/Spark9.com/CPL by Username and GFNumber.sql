use dev_alliant

declare @GFNumber varchar(200) = '',
        @username varchar(200) = ''


select  c.iclid
       ,c.FileNumber
       ,c.EscrowID as OfficeID
       ,b.agency
       ,c.GFNumber
       ,c.code
       ,c.icldate
       ,c.StateName
from    dbo.t_usercompany a inner join
        dbo.t_company b inner join
        dbo.t_icl c
     on c.EscrowID = b.cid
     on b.cid = a.cid
  where a.username = @username
    and c.GFNumber = @GFNumber
  order by icldate desc