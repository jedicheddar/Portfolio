use ANTIC

DECLARE @acct as varchar(20) = ''

select
an.ACTNUMST Account_Number,
a.ACTDESCR Account_Name
 
from GL00100 a --account master
 
inner join GL00105 an --account number
on a.ACTINDX = an.ACTINDX

where a.ACTIVE = 1
  and an.ACTNUMST = @acct
order by an.ACTNUMST