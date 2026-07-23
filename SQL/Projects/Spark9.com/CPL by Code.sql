declare @code varchar(10) = '' -- place the code here

select  c.*
from    dbo.t_company b inner join
        dbo.t_icl c
     on c.EscrowID = b.cid inner join
        dbo.t_ClosingLetter t
     on t.ClosingLetterID = c.ClosingLetterID inner join
        dbo.CPLProperties p
     on t.ClosingLetterID = p.CPLID
  where c.code = @code