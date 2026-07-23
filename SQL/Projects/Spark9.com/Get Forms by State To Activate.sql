GO

DECLARE @state varchar(2) = '' -- Enter the state

IF (@state <> '')
BEGIN

  SELECT  'INSERT INTO #formTable (form) VALUES (''' + replace([FormName], '''', '''''') + ''')',
          [version],
          [PFormID]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  AND     [Active] = 0
  AND     [version] >= GETDATE() - 15
  ORDER BY [version] desc

END
ELSE
BEGIN
  PRINT 'Please enter a state'
END