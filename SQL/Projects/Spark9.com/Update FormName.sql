DECLARE @newformname VARCHAR(200),
        @oldformname VARCHAR(200),
        @formstate VARCHAR(2)

SET @oldformname = '' -- The old form name
SET @newformname = '' -- The new form name
SET @formstate = ''

SELECT  *
FROM    dbo.t_policyforms
WHERE   [FormName] = @oldformname
AND     [State] = @formstate

IF (@newformname != '')
BEGIN
  UPDATE  dbo.t_policyforms
  SET     [FormName] = @newformname
  WHERE   [FormName] = @oldformname
  AND     [State] = @formstate

  SELECT  *
  FROM    dbo.t_policyforms
  where   [FormName] = @newformname
  AND     [State] = @formstate
END