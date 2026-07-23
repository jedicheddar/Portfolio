DECLARE @agentID VARCHAR(30) = '',
        @destType VARCHAR(30) = '',
        @action VARCHAR(100) = '',
        @delete BIT = 0

SELECT  *
FROM    [dbo].[sysdest]
WHERE   [entityID] = CASE WHEN @agentID = '' THEN [entityID] ELSE @agentID END
AND     [destType] = CASE WHEN @destType = '' THEN [destType] ELSE @destType END
AND     [action] LIKE CASE WHEN @action = '' THEN [action] ELSE '%' + @action + '%' END
ORDER BY [entityID], [action], [destType]

IF (@delete = 1)
BEGIN
  DELETE
  FROM    [dbo].[sysdest]
  WHERE   [entityID] = CASE WHEN @agentID = '' THEN [entityID] ELSE @agentID END
  AND     [destType] = CASE WHEN @destType = '' THEN [destType] ELSE @destType END
  AND     [action] LIKE CASE WHEN @action = '' THEN [action] ELSE '%' + @action + '%' END
  
  SELECT  *
  FROM    [dbo].[sysdest]
  WHERE   [entityID] = CASE WHEN @agentID = '' THEN [entityID] ELSE @agentID END
  AND     [destType] = CASE WHEN @destType = '' THEN [destType] ELSE @destType END
  AND     [action] LIKE CASE WHEN @action = '' THEN [action] ELSE '%' + @action + '%' END
  ORDER BY [entityID], [action], [destType]
END