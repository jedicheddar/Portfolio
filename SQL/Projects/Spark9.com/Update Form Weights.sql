USE [alliant_test]
--USE [alliant]

DECLARE @update BIT = 0

SELECT  p.[FormName],
        p.[Sta--te],
        p.[Weight] AS 'oldWeight',
        w.[newWeight]
FROM    [tempdb].[dbo].[##weightTable] w inner join
        [t_policyforms] p
ON      w.[formName] = p.[FormName]
AND     w.[stateID] = p.[State]
WHERE   p.[active] = 1
ORDER BY p.[State],p.[FormName]

IF (@update = 1 AND @@ROWCOUNT > 0)
BEGIN
  --Update
  UPDATE  [t_policyforms]
  SET     [Weight] = w.[newWeight]
  FROM    [tempdb].[dbo].[##weightTable] w inner join
          [t_policyforms] p
  ON      w.[formName] = p.[FormName]
  AND     w.[stateID] = p.[State]
  AND     w.[newWeight] <> p.[Weight]
  --Validate
  SELECT  p.[FormName],
          p.[State],
          p.[Weight] AS 'oldWeight',
          w.[newWeight]
  FROM    [tempdb].[dbo].[##weightTable] w inner join
          [t_policyforms] p
  ON      w.[formName] = p.[FormName]
  AND     w.[stateID] = p.[State]
  WHERE   p.[active] = 1
  ORDER BY p.[State],p.[FormName]
END