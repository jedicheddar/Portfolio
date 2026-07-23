USE [COMPASS]

DECLARE @agent VARCHAR(10) = '',
        @month INTEGER = 0,
        @year INTEGER = 0

IF (@month = 0)
  SET @month = MONTH(DATEADD(MONTH,-1,GETDATE()))

IF (@year = 0)
  SET @year = YEAR(DATEADD(MONTH,-1,GETDATE()))

SELECT  bf.[agentID],
        @month AS [Month],
        @year AS [Year],
        SUM(bf.[liabilityAmount])   AS [BF Liability],
        SUM(b.[liabilityAmount])    AS [B Liability],
        SUM(gp.[liabilityAmount])   AS [GP Liability],
        SUM(bf.[grossPremiumDelta]) AS [BF Gross],
        SUM(b.[grossPremiumDelta])  AS [B Gross],
        SUM(gp.[grossPremiumDelta]) AS [GP Gross],
        SUM(bf.[netPremiumDelta]) AS [BF Net],
        SUM(b.[netPremiumDelta])  AS [B Net],
        SUM(gp.[netPremiumDelta]) AS [GP Net],
        SUM(bf.[retainedPremiumDelta]) AS [BF Retained],
        SUM(b.[retainedPremiumDelta])  AS [B Retained],
        SUM(gp.[retainedPremiumDelta]) AS [GP Retained]
FROM    (
        SELECT  DISTINCT
                b.[batchID],
                b.[agentID],
                SUM(bf.[liabilityDelta]) AS [liabilityAmount],
                SUM(bf.[grossDelta]) AS [grossPremiumDelta],
                SUM(bf.[netDelta]) AS [netPremiumDelta],
                SUM(bf.[retentionDelta]) AS [retainedPremiumDelta]
        FROM    [dbo].[batchform] bf INNER JOIN
                [dbo].[batch] b
        ON      bf.[batchID] = b.[batchID] INNER JOIN
                [dbo].[period] p
        ON      b.[periodID] = p.[periodID]
        WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
        AND     p.[periodMonth] = @month
        AND     p.[periodYear] = @year
        GROUP BY b.[batchID],b.[agentID],b.[receivedDate]
        ) bf INNER JOIN
        (
        SELECT  DISTINCT
                b.[batchID],
                b.[agentID],
                b.[liabilityAmount],
                b.[grossPremiumDelta],
                b.[netPremiumDelta],
                b.[retainedPremiumDelta]
        FROM    [dbo].[batch] b INNER JOIN
                [dbo].[period] p
        ON      b.[periodID] = p.[periodID]
        WHERE   b.[agentID] = CASE WHEN @agent = '' THEN b.[agentID] ELSE @agent END
        AND     p.[periodMonth] = @month
        AND     p.[periodYear] = @year
        ) b
ON      bf.[batchID] = b.[batchID]
AND     bf.[agentID] = b.[agentID] INNER JOIN
        (
        SELECT  b.[batchID] AS [batchID],
                [CustomerID] AS [agentID],
                SUM([Liability]) AS [liabilityAmount],
                SUM([NetPremium]) AS [netPremiumDelta],
                SUM([GrossPremium]) AS [grossPremiumDelta],
                SUM([RetainedPremium]) AS [retainedPremiumDelta]
        FROM    [ANTIC].[dbo].[cstbInvoiceArchive] a INNER JOIN
                [dbo].[batch] b
        ON      a.[BatchID] = b.[batchID] INNER JOIN
                [dbo].[period] p
        ON      b.[periodID] = p.[periodID]
        WHERE   [CustomerID] = CASE WHEN @agent = '' THEN [CustomerID] ELSE @agent END
        AND     p.[periodMonth] = @month
        AND     p.[periodYear] = @year
        GROUP BY b.[batchID],[CustomerID]
        ) gp
ON      bf.[batchID] = gp.[batchID]
AND     bf.[agentID] = gp.[agentID]
GROUP BY bf.[agentID]