DECLARE @code VARCHAR(200) = ''

SELECT  c.iclid
       ,c.FileNumber
       ,c.GFNumber
       ,t.CPLType
       ,bc.beneficiaryID
       ,l.BeneficiaryType
       ,l.lender_comp_name AS 'Name'
       ,l.lender_addr1
       ,l.lender_city
       ,l.lender_state
       ,l.lender_zip
       ,l.lender_phone
   FROM dbo.t_icl c INNER JOIN
        dbo.BeneficiaryCpl bc
     ON c.iclid = bc.CplId INNER JOIN
        dbo.t_lenders l
     ON bc.BeneficiaryId = l.lender_id INNER JOIN
        dbo.t_ClosingLetter t
     ON t.ClosingLetterID = c.ClosingLetterID
  WHERE c.code = @code