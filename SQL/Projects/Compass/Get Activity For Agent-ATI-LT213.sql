/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @agentID VARCHAR(30) = '',
        @category VARCHAR(20) = '',
        @year INTEGER = 2021


SELECT  *
FROM    [dbo].[GetActivityTable](@category,@year) a
WHERE   [agentID] = CASE WHEN @agentID = '' THEN [agentID] ELSE @agentID END
ORDER BY [agentID]