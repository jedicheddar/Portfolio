GO

DECLARE @state varchar(2) = '' -- Enter the state

IF (@state <> '')
BEGIN
  SELECT  [PFormID],
          [FormName],
          [FileName],
          [Version],
          [Active],
          [SignatureOffset],
          [FormId],
          [Type],
          [ActiveId]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  ORDER BY [FormName] asc

  SELECT  STRING_AGG([PFormID], ',') 
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  AND     [Active] = 1
END
ELSE
BEGIN
  PRINT 'Please enter a state'
END