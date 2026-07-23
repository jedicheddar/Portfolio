USE [alliant]

DECLARE @agentID VARCHAR(30) = '434040',
        @dateStart DATETIME = '2019-01-01',
        @dateEnd DATETIME = '2019-03-31'

SELECT  [IclID],
        dbo.Dateonly([icldate]) as IclDate,
        [Agent] as [UserName], 
        C.[cintid] AS AgentID, 
        C.[agency], 
        C.[state] as AgencyState, 
        [StateName] as PropertyState,
        [LenderName], 
        [GFNumber], 
        I.[Status], 
        [Code], 
        dbo.Dateonly([StatusChangeDate]) AS [Status Change Date], 
        [TransactionType], 
        [lender_id] AS [LenderID],
        c.[cid] AS [Office ID]
FROM    [dbo].[t_icl] I LEFT OUTER JOIN 
        [dbo].[t_company] C
ON      I.[EscrowID] = C.[cid]
WHERE   dbo.DateOnly([ICLDate]) BETWEEN @dateStart AND @dateEnd
AND     c.[cintid] = CASE WHEN @agentID = '' THEN c.[cintid] ELSE @agentID END
ORDER BY [Agent],[LenderName],[GFNumber]