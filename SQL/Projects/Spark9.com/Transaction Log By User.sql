--USE [dev_alliant]
--USE [alliant_test]
USE [alliant]
GO

DECLARE @user VARCHAR(100) = 'beth@trusttitlefl.com' -- User

IF (@user <> '')
BEGIN
  SELECT  t.[TransactionLogID]
         ,t.[TimeStamp]
         ,t.[TransactionServiceType]
         ,t.[CompanyID]
         ,t.[CPLNumber]
         ,t.[PolicyNumber]
         ,t.[GFNumber]
         ,t.[Actor]
         ,t.[UserID]
  FROM      [dbo].[TransactionLog] t
  WHERE   t.[UserID] = @user
  ORDER BY [TimeStamp] DESC
END
ELSE
BEGIN
  SELECT  TOP 1000
          t.[TransactionLogID]
         ,t.[TimeStamp]
         ,t.[TransactionServiceType]
         ,t.[CompanyID]
         ,t.[CPLNumber]
         ,t.[PolicyNumber]
         ,t.[GFNumber]
         ,t.[Actor]
         ,t.[UserID]
  FROM      [dbo].[TransactionLog] t
  ORDER BY [TimeStamp] DESC
END
GO


