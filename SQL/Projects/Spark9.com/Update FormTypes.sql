use alliant

SELECT  state,
        FormName,
        Type
FROM    [t_policyforms]

DECLARE @insertTable TABLE (stateInit varchar(2),form varchar(200),formType varchar(20))
INSERT INTO @insertTable (stateInit,form,formType)
SELECT  state,
        FormName,
        Type
FROM    [dev_alliant].[dbo].[t_policyforms]
where   Type IS NOT NULL

select  *
from    @insertTable

UPDATE  t_policyforms
SET     Type = a.formType
FROM    @insertTable a
where   state = a.stateInit
and     FormName = a.form

select  *
from    t_policyforms
where   type is not NULL