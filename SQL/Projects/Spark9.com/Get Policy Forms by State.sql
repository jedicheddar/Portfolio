USE [alliant]
GO

DECLARE @state varchar(2) = '' -- Enter the state

IF (@state <> '')
BEGIN

  SELECT  [PFormID]
         ,[FormName]
         ,[FileName]
         ,[Active]
         ,[PJ]
         ,[type]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  ORDER BY [FormName] asc

END
ELSE
BEGIN
  PRINT 'Please enter a state'
END