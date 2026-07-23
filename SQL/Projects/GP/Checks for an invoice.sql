declare @invoice varchar(21) = '1000514'
declare @doctype int = 1

USE ANTIC

select * from 
(select CUSTNMBR, APFRDCNM, APFRDCTY, APPTOAMT from RM20201
 where APTODCNM like RTRIM(@invoice)+'%' and APTODCTY = @doctype 
 union 
 select CUSTNMBR, APFRDCNM, APFRDCTY, APPTOAMT from RM30201
 where APTODCNM like RTRIM(@invoice)+'%'  and APTODCTY = @doctype) a --apply
 
left outer join 
(select DOCNUMBR, RMDTYPAL, DOCDATE, ORTRXAMT, CURTRXAM, CHEKNMBR, CSHRCTYP
 from RM20101 
 union 
 select DOCNUMBR, RMDTYPAL, DOCDATE, ORTRXAMT, CURTRXAM, CHEKNMBR, CSHRCTYP 
 from RM30101 ) t -- transactions
	on a.APFRDCNM = t.DOCNUMBR and a.APFRDCTY = t.RMDTYPAL
 
 
 
 
 
 
 --select APTODCNM from rm20201 group by APTODCNM having COUNT(*) > 3