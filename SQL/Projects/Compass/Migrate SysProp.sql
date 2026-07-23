USE [COMPASS]

DECLARE @appCode VARCHAR(30) = '',
        @objAction VARCHAR(30) = '',
        @objProperty VARCHAR(30) = '',
        @objID VARCHAR(30) = '',
        @testToProd BIT = 1,
        @migrate BIT = 0

IF (@migrate = 1)
BEGIN
  SELECT  j.[appCode] AS [testApp],
          j.[objAction] AS [testAction],
          j.[objProperty] AS [testProperty],
          j.[objID] AS [testID],
          j.[objValue] AS [testValue],
          j.[objName] AS [testName],
          j.[objDesc] AS [testDesc],
          j.[objRef] AS [testRef],
          j.[comments] AS [testComments],
          r.[appCode] AS [prodApp],
          r.[objAction] AS [prodAction],
          r.[objProperty] AS [prodProperty],
          r.[objID] AS [prodID],
          r.[objValue] AS [prodValue],
          r.[objName] AS [prodName],
          r.[objDesc] AS [prodDesc],
          r.[objRef] AS [prodRef],
          r.[comments] AS [prodComments]
  FROM    [jefferson].[COMPASS].[dbo].[sysprop] j FULL OUTER JOIN
          [dbo].[sysprop] r
  ON      r.[appCode] = j.[appCode]
  AND     r.[objAction] = j.[objAction]
  AND     r.[objProperty] = j.[objProperty]
  AND     r.[objID] = j.[objID]
  AND     r.[objValue] = j.[objValue]
  WHERE  (r.[appCode] = CASE WHEN @appCode = '' THEN r.[appCode] ELSE @appCode END
  AND     r.[objAction] = CASE WHEN @objAction = '' THEN r.[objAction] ELSE @objAction END
  AND     r.[objProperty] = CASE WHEN @objProperty = '' THEN r.[objProperty] ELSE @objProperty END
  AND     r.[objID] = CASE WHEN @objID = '' THEN r.[objID] ELSE @objID END)
  OR     (j.[appCode] = CASE WHEN @appCode = '' THEN j.[appCode] ELSE @appCode END
  AND     j.[objAction] = CASE WHEN @objAction = '' THEN j.[objAction] ELSE @objAction END
  AND     j.[objProperty] = CASE WHEN @objProperty = '' THEN j.[objProperty] ELSE @objProperty END
  AND     j.[objID] = CASE WHEN @objID = '' THEN j.[objID] ELSE @objID END)
  AND    (j.[appCode] IS NULL OR r.[appCode] IS NULL)
  ORDER BY r.[appCode],r.[objAction],r.[objProperty],r.[objID]

  IF (@testToProd = 1)
  BEGIN
    DELETE
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = CASE WHEN @appCode = '' THEN [appCode] ELSE @appCode END
    AND     [objAction] = CASE WHEN @objAction = '' THEN [objAction] ELSE @objAction END
    AND     [objProperty] = CASE WHEN @objProperty = '' THEN [objProperty] ELSE @objProperty END
    AND     [objID] = CASE WHEN @objID = '' THEN [objID] ELSE @objID END

    INSERT INTO [dbo].[sysprop] ([appCode],[objAction],[objProperty],[objID],[objValue],[objName],[objDesc],[objRef],[comments],[lastModified],[modifiedBy])
    SELECT  [appCode],
            [objAction],
            [objProperty],
            [objID],
            [objValue],
            [objName],
            [objDesc],
            [objRef],
            [comments],
            GETDATE(),
            'joliver@alliantnational.com'
    FROM    [jefferson].[COMPASS].[dbo].[sysprop]
    WHERE   [appCode] = CASE WHEN @appCode = '' THEN [appCode] ELSE @appCode END
    AND     [objAction] = CASE WHEN @objAction = '' THEN [objAction] ELSE @objAction END
    AND     [objProperty] = CASE WHEN @objProperty = '' THEN [objProperty] ELSE @objProperty END
    AND     [objID] = CASE WHEN @objID = '' THEN [objID] ELSE @objID END
    AND     [objID] <> 'joliver@alliantnational.com'
  END
  ELSE
  BEGIN
    DELETE
    FROM    [COMPASS].[dbo].[sysprop]
    WHERE   [appCode] = CASE WHEN @appCode = '' THEN [appCode] ELSE @appCode END
    AND     [objAction] = CASE WHEN @objAction = '' THEN [objAction] ELSE @objAction END
    AND     [objProperty] = CASE WHEN @objProperty = '' THEN [objProperty] ELSE @objProperty END
    AND     [objID] = CASE WHEN @objID = '' THEN [objID] ELSE @objID END

    INSERT INTO [COMPASS].[dbo].[sysprop] ([appCode],[objAction],[objProperty],[objID],[objValue],[objName],[objDesc],[objRef],[comments],[lastModified],[modifiedBy])
    SELECT  [appCode],
            [objAction],
            [objProperty],
            [objID],
            [objValue],
            [objName],
            [objDesc],
            [objRef],
            [comments],
            GETDATE(),
            'joliver@alliantnational.com'
    FROM    [dbo].[sysprop]
    WHERE   [appCode] = CASE WHEN @appCode = '' THEN [appCode] ELSE @appCode END
    AND     [objAction] = CASE WHEN @objAction = '' THEN [objAction] ELSE @objAction END
    AND     [objProperty] = CASE WHEN @objProperty = '' THEN [objProperty] ELSE @objProperty END
    AND     [objID] = CASE WHEN @objID = '' THEN [objID] ELSE @objID END
  END
END

SELECT  j.[appCode] AS [testApp],
        j.[objAction] AS [testAction],
        j.[objProperty] AS [testProperty],
        j.[objID] AS [testID],
        j.[objValue] AS [testValue],
        j.[objName] AS [testName],
        j.[objDesc] AS [testDesc],
        j.[objRef] AS [testRef],
        j.[comments] AS [testComments],
        r.[appCode] AS [prodApp],
        r.[objAction] AS [prodAction],
        r.[objProperty] AS [prodProperty],
        r.[objID] AS [prodID],
        r.[objValue] AS [prodValue],
        r.[objName] AS [prodName],
        r.[objDesc] AS [prodDesc],
        r.[objRef] AS [prodRef],
        r.[comments] AS [prodComments]
FROM    [jefferson].[COMPASS].[dbo].[sysprop] j FULL OUTER JOIN
        [dbo].[sysprop] r
ON      r.[appCode] = j.[appCode]
AND     r.[objAction] = j.[objAction]
AND     r.[objProperty] = j.[objProperty]
AND     r.[objID] = j.[objID]
AND     r.[objValue] = j.[objValue]
WHERE  (r.[appCode] = CASE WHEN @appCode = '' THEN r.[appCode] ELSE @appCode END
AND     r.[objAction] = CASE WHEN @objAction = '' THEN r.[objAction] ELSE @objAction END
AND     r.[objProperty] = CASE WHEN @objProperty = '' THEN r.[objProperty] ELSE @objProperty END
AND     r.[objID] = CASE WHEN @objID = '' THEN r.[objID] ELSE @objID END)
OR     (j.[appCode] = CASE WHEN @appCode = '' THEN j.[appCode] ELSE @appCode END
AND     j.[objAction] = CASE WHEN @objAction = '' THEN j.[objAction] ELSE @objAction END
AND     j.[objProperty] = CASE WHEN @objProperty = '' THEN j.[objProperty] ELSE @objProperty END
AND     j.[objID] = CASE WHEN @objID = '' THEN j.[objID] ELSE @objID END)
AND    (j.[appCode] IS NULL OR r.[appCode] IS NULL)
ORDER BY r.[appCode],r.[objAction],r.[objProperty],r.[objID]