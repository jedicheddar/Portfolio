GO

DECLARE @state varchar(2) = '', -- Enter the state
        @id varchar(max) = '' -- Enter the form IDs

DECLARE @sql NVARCHAR(MAX) = ''

IF (@state <> '' AND @id <> '')
BEGIN
  SET @sql = 'SELECT  [FormName],
                      [Active]
              FROM    [dbo].[t_policyforms]
              WHERE   [State] = ''' + @state + '''
              AND     [PFormID] IN (' + @id + ')'
  EXEC sp_executesql @sql

  
  SET @sql = 'UPDATE  [dbo].[t_policyforms]
              SET     [Active] = 0
              WHERE   [State] = ''' + @state + '''
              AND     [PFormID] IN (' + @id + ')'
  EXEC sp_executesql @sql
  
  SET @sql = 'SELECT  [FormName],
                      [Active]
              FROM    [dbo].[t_policyforms]
              WHERE   [State] = ''' + @state + '''
              AND     [PFormID] IN (' + @id + ')'
  EXEC sp_executesql @sql
END
ELSE
BEGIN
  PRINT 'Please enter a state and id(s)'
END