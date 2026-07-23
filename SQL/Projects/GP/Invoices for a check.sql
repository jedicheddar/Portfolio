declare @pmt varchar(21) = '00100403'

USE ANTIC

select a.*, t.* from 
(select APTODCNM Invoice, APTODCTY, APTODCDT [Invoice Date], APPTOAMT [Amount Applied] 
 from RM20201 
 where APFRDCNM = @pmt and APFRDCTY = 9
 union 
 select APTODCNM Invoice, APTODCTY, APTODCDT [Invoice Date], APPTOAMT [Amount Applied] 
 from RM30201 
 where APFRDCNM = @pmt and APFRDCTY = 9) a --apply data
 
 left outer join 
(select DOCNUMBR, RMDTYPAL, CSPORNBR FileNo, BACHNUMB Batch, ORTRXAMT [Invoice Amount], CURTRXAM [Outstanding], ORTRXAMT - CURTRXAM Applied  
 from RM20101
 union 
 select DOCNUMBR, RMDTYPAL, CSPORNBR FileNo, BACHNUMB Batch, ORTRXAMT [Invoice Amount], CURTRXAM [Outstanding], ORTRXAMT - CURTRXAM Applied  
 from RM30101) t -- transactions
	on a.Invoice = t.DOCNUMBR and  a.APTODCTY = t.RMDTYPAL
 