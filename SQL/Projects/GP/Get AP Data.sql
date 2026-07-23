use ANTIC
declare @account varchar(25) = '1-50025-%'

select 
g.JRNENTRY [Journal Entry], 
g.ACTNUMST [Account Number], 
g.TRXDATE [Date], 
g.Amount, 
g.ORMSTRID [Vendor ID],
g.ORMSTRNM [Vendor Name], 
g.ORDOCNUM [Invoice Number],
coalesce(p.DOCDATE, '1900-01-01') [Invoice Date], 
coalesce(p.DUEDATE, '1900-01-01') [Due Date],
coalesce(p.TRXDSCRN,'') Reference --description from Payables trx

from
(select g.JRNENTRY, a.ACTNUMST, g.TRXDATE, g.DEBITAMT - g.CRDTAMNT Amount, g.ORMSTRID, g.ORMSTRNM, g.ORDOCNUM, g.ORTRXTYP
 from GL20000 g
 inner join GL00105 a
	on g.ACTINDX = a.ACTINDX
where a.ACTNUMST like @account

 union
 
 select g.JRNENTRY, a.ACTNUMST, g.TRXDATE, g.DEBITAMT - g.CRDTAMNT Amount, g.ORMSTRID, g.ORMSTRNM, g.ORDOCNUM, g.ORTRXTYP
 from GL30000 g
 inner join GL00105 a
	on g.ACTINDX = a.ACTINDX
where a.ACTNUMST like @account
and   year(TRXDATE) >= 2013) g

left outer join 
(select VENDORID, DOCTYPE, DOCNUMBR, DOCDATE, DUEDATE, TRXDSCRN 
 from PM20000
 union
 select VENDORID, DOCTYPE, DOCNUMBR, DOCDATE, DUEDATE, TRXDSCRN 
 from PM30200
 ) p 
	on g.ORTRXTYP = p.DOCTYPE and g.ORMSTRID = p.VENDORID and g.ORDOCNUM = p.DOCNUMBR
order by g.trxdate
