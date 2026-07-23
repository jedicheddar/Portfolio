SET NOCOUNT ON

DECLARE @oldState VARCHAR(2) = 'MI',
        @newState VARCHAR(2) = 'MS',
        @oldStateName VARCHAR(50),
        @newStateName VARCHAR(50),
        @isProd bit = 0, -- Change to 1 for production
        @isFound int = 0

SELECT  @oldStateName = [state_name]
FROM    [dbo].[t_states]
WHERE   [state_abbr] = @oldState

SELECT  @newStateName = [state_name]
FROM    [dbo].[t_states]
WHERE   [state_abbr] = @newState
        
/***** DEVELOPMENT *****/
USE [dev_alliant]
PRINT '--DEVELOPMENT--'

SET @isFound = 0
IF @newStateName <> ''
BEGIN
  SELECT  @isFound = COUNT(*)
  FROM    [dbo].[t_policyforms]
  WHERE   [state] = @oldState

  IF @isFound > 0
  BEGIN

    PRINT 'Migrating forms from state ' + @oldStateName + ' to ' + @newStateName
    UPDATE  [dbo].[t_policyforms]
    SET     [state] = @newState
    WHERE   [state] = @oldState
  END
  ELSE
    PRINT 'No forms for state ' + @oldStateName + ' to migrate' 
END
ELSE
  PRINT 'State ' + @newState + ' does not exist'
  
PRINT ''
/***** TEST *****/
USE [alliant_test]
PRINT '--TEST--'

SET @isFound = 0
IF @newStateName <> ''
BEGIN
  SELECT  @isFound = COUNT(*)
  FROM    [dbo].[t_policyforms]
  WHERE   [state] = @oldState

  IF @isFound > 0
  BEGIN

    PRINT 'Migrating forms from state ' + @oldStateName + ' to ' + @newStateName
    UPDATE  [dbo].[t_policyforms]
    SET     [state] = @newState
    WHERE   [state] = @oldState
  END
  ELSE
    PRINT 'No forms for state ' + @oldStateName + ' to migrate' 
END
ELSE
  PRINT 'State ' + @newState + ' does not exist'
  
PRINT ''
/***** PRODUCTION *****/
USE [alliant]
PRINT '--PRODUCTION--'

IF @newStateName <> '' AND @isProd = 1
BEGIN
  PRINT 'Migrating forms from state ' + @oldStateName + ' to ' + @newStateName
  UPDATE  [dbo].[t_policyforms]
  SET     [state] = @newState
  WHERE   [state] = @oldState
END
ELSE
BEGIN
  IF @newStateName = ''
    PRINT 'State ' + @newState + ' does not exist'
  ELSE
    PRINT 'Did not migrate forms from ' + @newStateName
END