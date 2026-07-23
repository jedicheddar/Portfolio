USE [COMPASS]

DECLARE @stateID VARCHAR(20) = 'CO',
        @effYear INTEGER = 2017

IF (@effYear = 0)
  SET @effYear = YEAR(GETDATE())


SELECT  DISTINCT
        p.[policyID] AS [Policy No.],
        CASE 
         WHEN sf.[formCode] LIKE '%Loan%'  THEN 'Loan'
         WHEN sf.[formCode] LIKE '%Owner%' THEN 'Owners'
         ELSE
          CASE sf.[insuredType]
           WHEN 'L' THEN 'Loan'
           WHEN 'O' THEN 'Owners'
           WHEN 'B' THEN 'Both'
          END
        END AS [Form Type],
        p.[agentID] AS [Agent ID],
        p.[fileNumber] AS [Agent File No.],
        p.[liabilityAmount] AS [Liability Amount],
        p.[issueDate] as [Issue Date],
        p.[effDate] AS [Effective Date],
        p.[grossPremium] AS [Premium Gross],
        p.[netPremium] AS [Premium Net],
        gp.[payOffDate] AS [Date Paid],
        gp.[invoiceDate] AS [Invoice Date]
FROM    [dbo].[policy] p INNER JOIN
        (
        SELECT  [agentID],
                [policyID],
                b.[batchID],
                [stateID]
        FROM    [dbo].[batch] b INNER JOIN
                [dbo].[batchform] bf
        ON      b.[batchID] = bf.[batchID]
        ) b
ON      p.[policyID] = b.[policyID]
AND     p.[agentID] = b.[agentID]
AND     p.[stateID] = b.[stateID] LEFT OUTER JOIN
        [dbo].[stateform] sf
ON      p.[formID] = sf.[formID]
AND     p.[stateID] = sf.[stateID]
AND     sf.[formType] = 'P' LEFT OUTER JOIN
        (
        SELECT  [CUSTNMBR] AS [agentID],
                [DOCNUMBR] AS [policyID],
                MIN([DINVPDOF]) AS [payOffDate],
                MIN([POSTDATE]) AS [invoiceDate]
        FROM    [ANTIC].[dbo].[RM20101]
        WHERE   [DINVPDOF] IS NOT NULL
        GROUP BY [CUSTNMBR], [DOCNUMBR]
        ) gp
ON      p.[agentID] = gp.[agentID]
AND     CONVERT(VARCHAR, p.[policyID]) = CONVERT(VARCHAR, gp.[policyID])
WHERE   YEAR(p.[effDate]) = @effYear
AND     p.[stateID] = CASE WHEN @stateID = '' THEN p.[stateID] ELSE @stateID END
ORDER BY p.[policyID]
