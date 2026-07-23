SET NOCOUNT ON

DECLARE @state varchar(2) = '', -- Enter the state
        @isProd bit = 1, -- Change to 1 for production
        @isGroup bit = null
        
USE [dev_alliant]

SELECT  @isGroup=[isGroup]
FROM    dbo.t_states
WHERE   [state_abbr] = @state

IF @isGroup IS NULL
BEGIN
  PRINT 'Please enter a state'
  RETURN
END

IF @isGroup = 0
BEGIN
  PRINT 'Activating the state ' + @state + ' in the development environment'
  UPDATE  dbo.t_states
  SET     IsGroup = 1
  WHERE   [state_abbr] = @state
END
ELSE
BEGIN
  PRINT 'State ' + @state + ' already active in development'
END

USE [alliant_test]

SELECT  @isGroup=[isGroup]
FROM    dbo.t_states
WHERE   [state_abbr] = @state

IF @isGroup = 0
BEGIN
  PRINT 'Activating the state ' + @state + ' in the test environment'
  UPDATE  dbo.t_states
  SET     IsGroup = 1
  WHERE   [state_abbr] = @state
END
ELSE
BEGIN
  PRINT 'State ' + @state + ' already active in test'
END

USE [alliant]

SELECT  @isGroup=[isGroup] 
FROM    dbo.t_states
WHERE   [state_abbr] = @state

IF @isGroup = 0 AND @isProd = 1
BEGIN
  PRINT 'Activating the state ' + @state + ' in the production environment'
  UPDATE  dbo.t_states
  SET     IsGroup = 1
  WHERE   [state_abbr] = @state
END
ELSE
BEGIN
  PRINT 'State ' + @state + ' not activated in production'
END