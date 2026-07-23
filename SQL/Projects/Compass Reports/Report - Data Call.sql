USE [COMPASS]

DECLARE @startPeriodID INTEGER = 201201,
        @endPeriodID INTEGER = 201809,
        @stateID VARCHAR(10) = 'ALL',
        @agentID VARCHAR(30) = 'ALL',
		@ranges VARCHAR(MAX) = '500000,750000,3000000,10000000,20000000,50000000'
        
EXEC [dbo].[spReportDataCall] @startPeriodID = @startPeriodID, @endPeriodID = @endPeriodID, @stateID = @stateID, @agentID = @agentID, @ranges = @ranges