USE [COMPASS]
GO

DECLARE @state varchar(2) = '' -- Enter the state

  UPDATE [dbo].[state]
  SET    [active] = 1
  WHERE  [stateID] = @state

  SELECT * FROM [dbo].[state] WHERE [stateID] = @state
GO


