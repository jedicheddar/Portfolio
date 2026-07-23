DECLARE @startPeriodID INTEGER = 201901,
        @endPeriodID INTEGER = 201912,
        @stateID VARCHAR(10) = 'AZ',
        @agentID VARCHAR(30) = 'ALL'
        
EXEC [dbo].[spReportTransactionSummary] @startPeriodID = @startPeriodID, @endPeriodID = @endPeriodID, @stateID = @stateID, @agentID = @agentID, @UID = 'joliver@alliantnational.com'