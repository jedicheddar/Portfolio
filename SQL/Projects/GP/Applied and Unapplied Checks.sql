declare @cust varchar(15) = '031031'
declare @from datetime = getdate() - 1000
declare @to datetime = getdate()

USE ANTIC

select CUSTNMBR, DOCNUMBR, CHEKNMBR, CSHRCTYP, DOCDATE, ORTRXAMT [Pmt Amount], CURTRXAM Unapplied, ORTRXAMT - CURTRXAM Applied
from RM20101 
where CUSTNMBR = @cust
and VOIDSTTS = 0
and DOCDATE between @from and @to
and RMDTYPAL = 9
ORDER BY DOCNUMBR