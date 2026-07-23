USE [COMPASS]

DECLARE @agentID VARCHAR(30) = '',
        @UID VARCHAR(MAX) = 'joliver@alliantnational.com'

EXEC [dbo].[spAgentReviewClaim] @agentID = @agentID, @UID = @UID

EXEC [dbo].[spAgentReviewCorrective] @agentID = @agentID, @UID = @UID

EXEC [dbo].[spAgentReviewReceivable] @agentID = @agentID, @UID = @UID

EXEC [dbo].[spAgentReviewRemittance] @agentID = @agentID, @UID = @UID

EXEC [dbo].[spAgentReviewScore] @agentID = @agentID, @UID = @UID