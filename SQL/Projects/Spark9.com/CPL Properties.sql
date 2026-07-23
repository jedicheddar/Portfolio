use alliant

declare @code varchar(10) = '' -- place the code here

select  c.iclid
       ,c.GFNumber
       ,t.CPLType
       ,b.*
from    dbo.CPLProperties b inner join
        dbo.t_icl c
     on c.ICLID = b.CPLID inner join
        dbo.t_ClosingLetter t
     on t.ClosingLetterID = c.ClosingLetterID
  where c.code = @code