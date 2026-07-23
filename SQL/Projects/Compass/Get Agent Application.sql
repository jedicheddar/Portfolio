DECLARE @agentID VARCHAR(100) = ''

SELECT  *
FROM    [agentapplication]
WHERE   [agentID] = CASE WHEN @agentID = '' THEN [agentID] ELSE @agentID END
ORDER BY [dateCreated] DESC