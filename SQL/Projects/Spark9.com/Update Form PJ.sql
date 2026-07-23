GO

DECLARE @state varchar(2) = 'NV', -- Enter the state
        @form varchar(200) = 'NV Prelim Commitment'
        
IF (@state <> '')
BEGIN

  USE [dev_alliant]
  UPDATE  [dbo].[t_policyforms]
  SET     [PJ] = 1
  WHERE   [State] = @state
  AND     [FormName] = @form

  USE [alliant_test]
  UPDATE  [dbo].[t_policyforms]
  SET     [PJ] = 1
  WHERE   [State] = @state
  AND     [FormName] = @form

  USE [alliant]
  UPDATE  [dbo].[t_policyforms]
  SET     [PJ] = 1
  WHERE   [State] = @state
  AND     [FormName] = @form

END
ELSE
BEGIN
  PRINT 'Please enter a state'
END