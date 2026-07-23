DECLARE @state VARCHAR(20) = '',
        @update BIT = 0

IF (@state <> '' AND @update = 1)
BEGIN
  UPDATE  t2
  SET     [ActiveId] = t1.[PFormID]
  FROM    [t_policyforms] t1 INNER JOIN
          [t_policyforms] t2
  ON      t1.[State] = t2.[State]
  AND     t1.[FormName] = t2.[FormName]
  AND     t1.[State] = @state
  WHERE   t1.[Active] = 1
  AND     t2.[Active] = 0

  UPDATE  [t_policyforms]
  SET     [ActiveId] = null
  WHERE   [Active] = 1
END

SELECT  t1.[PFormID],
        t1.[FormName],
        t1.[State],
        t1.[Active],
        t1.[version],
        t1.[ActiveId],
        t2.[PFormID],
        t2.[Active],
        t2.[version],
        t2.[ActiveId]
FROM    [t_policyforms] t1 INNER JOIN
        [t_policyforms] t2
ON      t1.[State] = t2.[State]
AND     t1.[FormName] = t2.[FormName]
WHERE   t1.[Active] = 1
AND     t2.[Active] = 0
AND     t1.[State] = CASE WHEN @state = '' THEN t1.[State] ELSE @state END
ORDER BY t2.[FormName] DESC