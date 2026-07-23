use COMPASS

declare @policyID int = 0,
        @fileNumber varchar(30) = '',
        @amount decimal = 0

select  policyID,liabilityAmount
from    policy
where   policyID = @policyID

select  policyID,fileNumber,liabilityDelta
from    batchform
where   policyID = @policyID
and     fileNumber = @fileNumber
and     formType = 'P'

update  policy
set     liabilityAmount = @amount
where   policyID = @policyID

update  batchform
set     liabilityDelta = @amount
where   policyID = @policyID
and     fileNumber = @fileNumber
and     formType = 'P'

select  policyID,liabilityAmount
from    policy
where   policyID = @policyID

select  policyID,fileNumber,liabilityDelta
from    batchform
where   policyID = @policyID
and     fileNumber = @fileNumber
and     formType = 'P'