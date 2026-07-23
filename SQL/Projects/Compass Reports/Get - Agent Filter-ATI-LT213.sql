GO

DECLARE @userid VARCHAR(50) = ''

IF (@userid <> '')
  EXEC [dbo].[spAgentFilter] @UID = @userid

GO