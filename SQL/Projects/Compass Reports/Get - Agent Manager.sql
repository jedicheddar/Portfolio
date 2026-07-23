USE [COMPASS]

DECLARE @state VARCHAR(200) = '',
        @manager VARCHAR(200) = ''

IF (@state = '')
  SET @state = 'ALL'

IF (@manager = '')
  SET @manager = 'ALL'
  
CREATE TABLE #stateTable ([stateID] VARCHAR(2))
INSERT INTO #stateTable ([stateID])
SELECT [field] FROM [dbo].[GetEntityFilter] ('State', @state)
  
CREATE TABLE #managerTable ([uid] VARCHAR(1000))
INSERT INTO #managerTable ([uid])
SELECT [field] FROM [dbo].[GetEntityFilter] ('AgentManager', @manager)

SELECT  a.[agentID],
        a.[name],
        a.[stateID],
        am.[uid],
        am.[isPrimary],
        am.[stat]
FROM    [dbo].[agentmanager] am INNER JOIN
        [dbo].[agent] a
ON      a.[agentID] = am.[agentID]
AND     am.[isPrimary] = 1
AND     am.[stat] = 'A'
WHERE   a.[stateID] IN (SELECT [stateID] FROM #stateTable)
AND     am.[uid] IN (SELECT [uid] FROM #managerTable)

DROP TABLE #stateTable
DROP TABLE #managerTable