USE [COMPASS]

DECLARE @agentID VARCHAR(30) = '097151',
        @user VARCHAR(100) = 'joliver@alliantnational.com',
        @preview BIT = 1

EXEC [dbo].[spAlertClaimsRatio] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertERRScore] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertERRScoreDrop] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertQARCycle] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertQARScore] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertQARScoreDrop] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertReceivableBalance] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertReportGap] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertReserve] @agentID = @agentID, @user = @user, @preview = @preview

EXEC [dbo].[spAlertPolicyLastRemit] @agentID = @agentID, @user = @user, @preview = @preview, @lastRemit = 10

EXEC [dbo].[spAlertPolicyVolume] @agentID = @agentID, @user = @user, @preview = @preview, @unremmited = 1.50, @threeMonthAverage = 2.00

EXEC [dbo].[spAlertCPLVolume] @agentID = @agentID, @user = @user, @preview = @preview, @month1 = 2, @month2 = 3
