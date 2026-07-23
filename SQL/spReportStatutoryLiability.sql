GO
/****** Object:  StoredProcedure [dbo].[spReportStatutoryLiability]    Script Date: 4/14/2017 8:32:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spReportStatutoryLiability]
  @periodID INTEGER = 0,
  @stateID VARCHAR(100) = 'ALL'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  DECLARE @validPeriod BIT = 0

  CREATE TABLE #stateTable (stateID VARCHAR(2))
  INSERT INTO #stateTable ([stateID])
  SELECT [field] FROM [dbo].[GetEntityFilter] ('State', @stateID)
  
  IF @periodID = 0
    SELECT @periodID = MAX([periodID]) FROM [dbo].[period] WHERE [active] = 0

  SELECT  [agentID],
          [name],
          [stateID],
          [batchID],
          [fileNumber],
          [grossPremium],
          [netPremium],
          [ownerNum],
          [lenderNum],
          [ownerLiability],
          [lenderLiability],
          CASE
            WHEN [lenderLiability] = 0 AND [ownerLiability] = 0 THEN 0
            WHEN [lenderLiability] > 0 and [ownerLiability] = 0 THEN [lenderLiability]
            WHEN [lenderLiability] = 0 and [ownerLiability] > 0 THEN [ownerLiability]
            WHEN [lenderLiability] > [ownerLiability] THEN [lenderLiability]
            WHEN [lenderLiability] <= [ownerLiability] THEN [ownerLiability]
            ELSE 0
          END AS [reservableLiability],
          CASE
            WHEN [lenderLiability] = 0 AND [ownerLiability] = 0 THEN 'None'
            WHEN [lenderLiability] > 0 and [ownerLiability] = 0 THEN 'Lender Only'
            WHEN [lenderLiability] = 0 and [ownerLiability] > 0 THEN 'Owner Only'
            WHEN [lenderLiability] > [ownerLiability] THEN 'Lender Greater'
            WHEN [lenderLiability] <= [ownerLiability] THEN 'Owner Greater'
            ELSE 'Unknown'
          END AS [grouped]
  FROM    (
          SELECT  a.[agentID],
                  a.[name],
                  b.[stateID],
                  b.[batchID],
                  bf.[fileNumber],
                  SUM(bf.[grossDelta]) AS [grossPremium],
                  SUM(bf.[netDelta]) AS [netPremium],
                  SUM(CASE WHEN sf.[insuredType] = 'O' THEN bf.[liabilityDelta] ELSE 0 END) AS [ownerLiability],
                  SUM(CASE WHEN sf.[insuredType] = 'L' THEN bf.[liabilityDelta] ELSE 0 END) AS [lenderLiability],
                  SUM(CASE WHEN sf.[insuredType] = 'O' THEN 1 ELSE 0 END) AS [ownerNum],
                  SUM(CASE WHEN sf.[insuredType] = 'L' THEN 1 ELSE 0 END) AS [lenderNum]
          FROM    [dbo].[batch] b INNER JOIN
                  [dbo].[batchform] bf
          ON      bf.[batchID] = b.[batchID]
          AND     bf.[formType] = 'P' INNER JOIN
                  [dbo].[stateform] sf
          ON      sf.[stateID] = b.[stateID]
          AND     sf.[formID] = bf.[formID] INNER JOIN
                  #stateTable stateTable
          ON      sf.[stateID] = stateTable.[stateID] INNER JOIN
                  [dbo].[agent] a
          ON      b.[agentID] = a.[agentID]
          WHERE   b.[periodID] = @periodID
          GROUP BY a.[agentID],
                    a.[name],
                    b.[stateID],
                    b.[batchID],
                    bf.[fileNumber]
          ) a
  ORDER BY [agentID],
           [fileNumber]
END
