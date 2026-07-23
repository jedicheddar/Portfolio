/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @agentID VARCHAR(30) = '031031',
        @category VARCHAR(20) = '',
        @year INTEGER = 2021,
        @delete BIT = 0

IF (@delete = 1)
BEGIN
  DELETE FROM [dbo].[agentactivity] WHERE [agentID] = CASE WHEN @agentID = '' THEN [agentID] ELSE @agentID END AND [category] = CASE WHEN @category = '' THEN [category] ELSE @category END AND [year] = @year AND [type] = 'P'
  IF (@agentID = '' AND @category = '')
    UPDATE [dbo].[syskey] SET [seq] = 0 WHERE [type] = 'agentActivity'
END
ELSE
BEGIN
  SELECT  *
  FROM    [dbo].[GetActivityTable](@category,@year) a
  WHERE   [agentID] = CASE WHEN @agentID = '' THEN [agentID] ELSE @agentID END
  ORDER BY [agentID]
END