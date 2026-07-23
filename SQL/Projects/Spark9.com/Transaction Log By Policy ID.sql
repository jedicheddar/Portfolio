USE [dev_alliant]
USE [alliant_test]
USE [alliant]
GO

DECLARE @id INTEGER = 0,
        @outputXML BIT = 0

IF (@id > 0)
  IF (@outputXML = 0)
    SELECT  t.[TransactionLogID],
            t.[TimeStamp],
            t.[TransactionServiceType],
            t.[CompanyID],
            t.[PolicyNumber],
            t.[GFNumber],
            t.[Actor],
            t.[UserID],
            b.[Agency],
            b.[cintid]
    FROM    [dbo].[TransactionLog] t INNER JOIN
            [dbo].[t_policies] p
    ON      t.[PolicyNumber] = p.[policyid] INNER JOIN
            [dbo].[t_company] b
    ON      p.[cid] = b.[cid]
    WHERE   p.[policyid] = @id
    ORDER BY [TimeStamp] DESC
  ELSE
    SELECT  '<?xml version="1.0"?>' + CHAR(13) + 
            '<Transaction ' +
            'site="' + [site] + '" ' + 
            'actor="' + [Actor] + '" ' + 
            'type="' + [TransactionServiceType] + '" ' +  
            'agentID="' + [AgentID] + '" ' +  
            'companyID="' + [CompanyID] + '" ' +
            'GFnumber="' + [GFNumber] + '" ' +
            'policyNumber="' + [PolicyNumber] + '" ' +
            'liabilityAmount="' + CONVERT(VARCHAR, ISNULL([liabilityAmount],0)) + '" ' +
            'grossPremiumAmount="' + CONVERT(VARCHAR, ISNULL([grossPremiumAmount],0)) + '" ' +
            'NAICresidential="' + ISNULL([NAICresidential],'') + '" ' +
            'quoteID="' + ISNULL([quoteID],'') + '" ' + 
            'userID="' + [userID] + '" ' +
            'CPLnumber="' + ISNULL([CPLnumber],'') + '" ' + 
            'lenderID="' + ISNULL([lenderID],'') + '" ' +
            'policyTemplateID="' + [policyTemplateID] + '" ' +
            'effectiveDate="' + CONVERT(VARCHAR, ISNULL([effectiveDate],''),101) + '" ' +
            'issueDateTime="' + CONVERT(VARCHAR, ISNULL([IssueDate],''),101) + '" ' +
            ' />'
    FROM    [dbo].[TransactionLog]
    WHERE   [PolicyNumber] = @id
    ORDER BY [TimeStamp] DESC
GO


