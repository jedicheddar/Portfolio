USE [COMPASS]
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spReportICL]
	-- Add the parameters for the stored procedure here
  @year INTEGER = 0,
  @stateID VARCHAR(200) = 'ALL',
  @UID varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
  SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  
  DECLARE @agentID varchar(MAX) = 'ALL'
  
  SET @agentID = [dbo].[StandardizeAgentID](@agentID)
  
  CREATE TABLE #stateTable ([stateID] VARCHAR(2))
  INSERT INTO #stateTable ([stateID])
  SELECT [field] FROM [dbo].[GetEntityFilter] ('State', @stateID)
 
  CREATE TABLE #agentTable ([agentID] VARCHAR(30))
  INSERT INTO #agentTable ([agentID])
  SELECT a.[agentID] FROM [agent] a WHERE (a.[agentID] = (CASE  WHEN @agentID != 'ALL' THEN @agentID ELSE a.[agentID] END)) 
                                      AND (dbo.CanAccessAgent(@UID ,a.[agentID]) = 1)
  
  SELECT  a.[agentID],
          a.[name] AS [agentName],
          a.[stateID],
          a.[stat],
          am.[uid] AS [manager],
          [dbo].[GetRegion] (a.[stateID]) AS [regionID],
          aa.[year],
          aa.[month1],
          aa.[month2],
          aa.[month3],
          aa.[month4],
          aa.[month5],
          aa.[month6],
          aa.[month7],
          aa.[month8],
          aa.[month9],
          aa.[month10],
          aa.[month11],
          aa.[month12],
          aa.[category]
  FROM    [dbo].[agent] a INNER JOIN
          [dbo].[agentactivity] aa
  ON      a.[agentID] = aa.[agentID]
  AND     aa.[category] IN ('I','V','W','R')
  AND     aa.[type] = 'A' LEFT OUTER JOIN
          [dbo].[agentmanager] am
  ON      a.[agentID] = am.[agentID]
  AND     am.[isPrimary] = 1
  AND     am.[stat] = 'A'
  WHERE   a.[agentID] IN (SELECT [agentID] FROM #agentTable)
  AND     a.[stateID] IN (SELECT [stateID] FROM #stateTable)
  AND     aa.[year] = CASE WHEN @year = 0 THEN YEAR(GETDATE()) ELSE @year END
  ORDER BY a.[agentID]

  DROP TABLE #agentTable
  DROP TABLE #stateTable
END
GO
