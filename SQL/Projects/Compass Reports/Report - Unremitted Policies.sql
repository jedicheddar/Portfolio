DECLARE @stateID VARCHAR(10) = '',
        @agentID VARCHAR(30) = ''
        
EXEC [dbo].[spReportUnremittedPolicies] @stateID = @stateID, @agentID = @agentID