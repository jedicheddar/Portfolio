use alliant

select  *
from    dbo.t_ClosingLetter
where   stateinit = 'TX'

update  dbo.t_ClosingLetter
set     FooterDescription = 'Form T-51: Purchaser / Seller Insured Closing Service Letter'
where   CPLType in ('Buyer','Seller')
and     stateinit = 'TX'

update  dbo.t_ClosingLetter
set     FooterDescription = 'Form T-50: Insured Closing Service Letter'
where   CPLType in ('Lender')
and     stateinit = 'TX'

select  *
from    dbo.t_ClosingLetter
where   stateinit = 'TX'