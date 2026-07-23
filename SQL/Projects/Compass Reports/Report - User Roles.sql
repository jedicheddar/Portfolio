SELECT  u.[uid] AS [User ID],
        u.[name] AS [User Name], 
        ur.[value] AS [Role],
        r.[description] AS [Role Description]
FROM    [sysuser] u CROSS APPLY
        String_Split(u.[role], ',') ur INNER JOIN
        [sysrole] r
ON      ur.[value] = r.[roleID]
WHERE   [isActive] = 1
ORDER BY u.[uid]