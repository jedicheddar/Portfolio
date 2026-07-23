SELECT  a.[action] AS [Action],
        a.[description] AS [Action Description],
        ar.[value] AS [Role],
        r.[description] AS [Role Description]
FROM    [sysaction] a CROSS APPLY
        String_Split(a.[roles], ',') ar INNER JOIN
        [sysrole] r
ON      ar.[value] = r.[roleID]
WHERE   [isActive] = 1