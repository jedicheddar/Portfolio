GO

DECLARE @state varchar(2) = '', -- Enter the state
        @form varchar(max) = '' -- Enter the form name

IF (@state <> '' AND @form <> '')
BEGIN
  SELECT  [FormName],
          [Active]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  AND     [FormName] = @form
  
  UPDATE  [dbo].[t_policyforms]
  SET     [Active] = 0
  WHERE   [State] = @state
  AND     [FormName] = @form

  SELECT  [FormName],
          [Active]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  AND     [FormName] = @form
END
ELSE
BEGIN
  PRINT 'Please enter a state and form title'
END