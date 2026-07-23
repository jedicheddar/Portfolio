use alliant

declare @state varchar(2) = '' -- Enter the state

select  *
from    dbo.t_company b inner join
        dbo.t_icl c
     on c.EscrowID = b.cid
where   c.icldate > getdate() - 30
order by c.icldate desc