USE [dev_alliant]
USE [alliant_test]
USE [alliant]
GO

DECLARE @code VARCHAR(10) = '' -- File number

  SELECT  t.[TransactionLogID]
         ,t.[TimeStamp]
         ,t.[TransactionServiceType]
         ,t.[CompanyID]
         ,t.[CPLNumber]
         ,t.[GFNumber]
         ,c.[Code]
         ,l.[CPLType]
         ,c.[AttorneyID]
         ,t.[Actor]
         ,t.[UserID]
         ,b.[Agency]
  FROM      [dbo].[TransactionLog] t INNER JOIN
            [dbo].[t_icl] c
       ON t.[CPLNumber] = c.[iclid] INNER JOIN
            [dbo].[t_ClosingLetter] l
       ON l.[ClosingLetterID] = c.[ClosingLetterID] INNER JOIN
            [dbo].[t_company] b
       ON c.[EscrowID] = b.[cid]
  WHERE   c.[Code] = @code
  ORDER BY [TimeStamp] DESC
GO


