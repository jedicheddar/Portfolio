DECLARE @state VARCHAR(20) = '',
        @oldVersion INT = 0,
        @newVersion INT = 0

IF (@state <> '' AND @oldVersion <> 0 AND @newVersion <> 0)
BEGIN
  SELECT  [Letter],
          [Version],
          [Active]
  FROM    [dbo].[t_ClosingLetter]
  WHERE   [StateInit] = @state
  AND     [Version] = @oldVersion
  
  UPDATE  [dbo].[t_ClosingLetter]
  SET     [Active] = 0
  WHERE   [StateInit] = @state
  AND     [Version] = @oldVersion
  
  UPDATE  [dbo].[t_ClosingLetter]
  SET     [Active] = 1
  WHERE   [StateInit] = @state
  AND     [Version] = @newVersion

  SELECT  [Letter],
          [Version],
          [Active]
  FROM    [dbo].[t_ClosingLetter]
  WHERE   [StateInit] = @state
  AND     [Version] = @newVersion
END
ELSE
BEGIN
  PRINT 'Please enter a state and versions'
END