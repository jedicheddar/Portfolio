USE [COMPASS]

DECLARE @qarID INTEGER = 0,
        @count INTEGER = 0

IF (@qarID > 0)
BEGIN
  SELECT  @count = COUNT(*)
  FROM    [dbo].[qar]
  WHERE   [qarID] = @qarID
  AND     [stat] = 'C'

  IF (@count = 0)
  BEGIN
    PRINT 'QAR Not Found'
    RETURN
  END

  DELETE FROM [dbo].[qarnote] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qarsection] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qarfinding] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qaraction] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qarbp] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qaranswer] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qaraccount] WHERE [qarID]  = @qarID
  DELETE FROM [dbo].[qarfile] WHERE [qarID]  = @qarID

  UPDATE  [dbo].[qar]
  SET     [stat] = 'A'
  WHERE   [qarID] = @qarID
  AND     [stat] = 'C'
END