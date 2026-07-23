DECLARE @policies VARCHAR(MAX) = '',
        @batchID INTEGER = 0,
        @agentID VARCHAR(20) = '',
        @migrate BIT = 0

DECLARE @sql NVARCHAR(MAX) = ''

IF (@batchID > 0)
  SET @sql = 'SELECT ''batch'' AS [table], batchID AS [entityID], [agentID] FROM [batch] WHERE [batchID] = ' + CONVERT(VARCHAR, @batchID) + ' UNION ALL '

IF (@policies <> '')
  SET @sql = @sql + 'SELECT ''policies'' AS [table], [policyID] AS [policyID], [agentID] FROM [policy] WHERE [policyID] IN (' + @policies + ')'

IF (@sql <> '' AND @migrate = 0)
  EXEC sp_executesql @sql

IF (@migrate = 1 AND @policies <> '')
BEGIN
  SET @sql = @sql + 'UPDATE [policy] SET [agentID] = ''' + @agentID + ''' WHERE [policyID] IN (' + @policies + ')'
  EXEC sp_executesql @sql

  IF (@batchID > 0)
    SET @sql = 'SELECT ''batch'' AS [table], batchID AS [entityID], [agentID] FROM [batch] WHERE [batchID] = ' + CONVERT(VARCHAR, @batchID) + ' UNION ALL '

  SET @sql = @sql + 'SELECT ''policies'' AS [table], [policyID] AS [policyID], [agentID] FROM [policy] WHERE [policyID] IN (' + @policies + ')'
  EXEC sp_executesql @sql
END