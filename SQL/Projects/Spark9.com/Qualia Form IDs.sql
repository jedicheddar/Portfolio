DECLARE @stateID VARCHAR(30) = 'TX',
        @year INTEGER = 2021



SELECT  new.[FormName] AS [Form Name],
        new.[PFormID] AS [New Form ID],
        old.[PFormID] AS [Old Form ID]
FROM    [t_policyforms] new INNER JOIN
        [t_policyforms] old
ON      new.[FormName] = old.[FormName]
AND     new.[State] = old.[State]
WHERE   new.[State] = @stateID
AND     old.[Active] = 1
AND     YEAR(new.[Version]) = @year