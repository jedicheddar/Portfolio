USE [COMPASS]

DECLARE @action VARCHAR(30) = '',
        @testToProd BIT = 1,
        @migrate BIT = 0

IF (@migrate = 1)
BEGIN
  SELECT  j.[action],
          j.[description],
          j.[progExec],
          r.[action],
          r.[description],
          r.[progExec]
  FROM    [jefferson].[COMPASS].[dbo].[sysaction] j FULL OUTER JOIN
          [dbo].[sysaction] r
  ON      r.[action] = j.[action]
  WHERE   r.[action] LIKE CASE WHEN @action = '%%' THEN r.[action] ELSE '%' + @action + '%' END
  OR      j.[action] LIKE CASE WHEN @action = '%%' THEN j.[action] ELSE '%' + @action + '%' END
  AND    (j.[action] IS NULL OR r.[action] IS NULL)
  ORDER BY r.[action]

  IF (@testToProd = 1)
  BEGIN
    DELETE
    FROM    [dbo].[sysaction]
    WHERE   [action] LIKE CASE WHEN @action = '%%' THEN [action] ELSE '%' + @action + '%' END

    INSERT INTO [dbo].[sysaction] ([action],[description],[progExec],[isActive],[isAnonymous],[isSecure],[isLog],[isAudit],[roles],[userids],[addrs],[createDate],[emails],[emailSuccess],[emailFailure],[isEventsEnabled],[comments])
    SELECT  [action],
            [description],
            [progExec],
            [isActive],
            [isAnonymous],
            [isSecure],
            [isLog],
            [isAudit],
            [roles],
            [userids],
            [addrs],
            [createDate],
            [emails],
            [emailSuccess],
            [emailFailure],
            [isEventsEnabled],
            [comments]
    FROM    [jefferson].[COMPASS].[dbo].[sysaction]
    WHERE   [action] LIKE CASE WHEN @action = '%%' THEN [action] ELSE '%' + @action + '%' END
  END
  ELSE
  BEGIN
    DELETE
    FROM    [jefferson].[COMPASS].[dbo].[sysaction]
    WHERE   [action] LIKE CASE WHEN @action = '%%' THEN [action] ELSE '%' + @action + '%' END
    
    INSERT INTO [jefferson].[COMPASS].[dbo].[sysaction] ([action],[description],[progExec],[isActive],[isAnonymous],[isSecure],[isLog],[isAudit],[roles],[userids],[addrs],[createDate],[emails],[emailSuccess],[emailFailure],[isEventsEnabled],[comments])
    SELECT  [action],
            [description],
            [progExec],
            [isActive],
            [isAnonymous],
            [isSecure],
            [isLog],
            [isAudit],
            [roles],
            [userids],
            [addrs],
            [createDate],
            [emails],
            [emailSuccess],
            [emailFailure],
            [isEventsEnabled],
            [comments]
    FROM    [dbo].[sysaction]
    WHERE   [action] LIKE CASE WHEN @action = '%%' THEN [action] ELSE '%' + @action + '%' END
  END
END

SELECT  j.[action],
        j.[description],
        j.[progExec],
        r.[action],
        r.[description],
        r.[progExec]
FROM    [jefferson].[COMPASS].[dbo].[sysaction] j FULL OUTER JOIN
        [dbo].[sysaction] r
ON      r.[action] = j.[action]
WHERE   r.[action] LIKE CASE WHEN @action = '%%' THEN r.[action] ELSE '%' + @action + '%' END
OR      j.[action] LIKE CASE WHEN @action = '%%' THEN j.[action] ELSE '%' + @action + '%' END
AND    (j.[action] IS NULL OR r.[action] IS NULL)
ORDER BY r.[action]