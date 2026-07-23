DECLARE @codeType VARCHAR(30) = 'Processing',
        @code VARCHAR(30) = '',
        @testToProd BIT = 1,
        @migrate BIT = 0

IF (@migrate = 1)
BEGIN
  SELECT  j.[codeType] AS [testCodeType],
          j.[code] AS [testCode],
          j.[description] AS [testDesc],
          j.[type] AS [testType],
          r.[codeType] AS [prodCodeType],
          r.[code] AS [prodCode],
          r.[description] AS [prodDesc],
          r.[type] AS [prodType]
  FROM    [taft].[COMPASS_DVLP].[dbo].[syscode] j FULL OUTER JOIN
          [dbo].[syscode] r
  ON      r.[codeType] = j.[codeType]
  AND     r.[code] = j.[code]
  WHERE  (r.[codeType] = CASE WHEN @codeType = '' THEN r.[codeType] ELSE @codeType END
  AND     r.[code] = CASE WHEN @code = '' THEN r.[code] ELSE @code END)
  OR     (j.[codeType] = CASE WHEN @codeType = '' THEN j.[codeType] ELSE @codeType END
  AND     j.[code] = CASE WHEN @code = '' THEN j.[code] ELSE @code END)
  AND    (j.[codeType] IS NULL OR r.[codeType] IS NULL)
  ORDER BY j.[codeType],j.[code]

  IF (@testToProd = 1)
  BEGIN
    DELETE
    FROM    [dbo].[syscode]
    WHERE   [codeType] = CASE WHEN @codeType = '' THEN [codeType] ELSE @codeType END
    AND     [code] = CASE WHEN @code = '' THEN [code] ELSE @code END

    INSERT INTO [dbo].[syscode] ([codeType],[code],[description],[type],[isSecure],[comments])
    SELECT  j.[codeType],
            j.[code],
            j.[description],
            j.[type],
            j.[isSecure],
            j.[comments]
    FROM    [taft].[COMPASS_DVLP].[dbo].[syscode] j
    WHERE   j.[codeType] = CASE WHEN @codeType = '' THEN j.[codeType] ELSE @codeType END
    AND     j.[code] = CASE WHEN @code = '' THEN j.[code] ELSE @code END
    ORDER BY j.[codeType],j.[code]
  END
  ELSE
  BEGIN
    DELETE
    FROM    [taft].[COMPASS_DVLP].[dbo].[syscode]
    WHERE   [codeType] = CASE WHEN @codeType = '' THEN [codeType] ELSE @codeType END
    AND     [code] = CASE WHEN @code = '' THEN [code] ELSE @code END

    INSERT INTO [taft].[COMPASS_DVLP].[dbo].[syscode] ([codeType],[code],[description],[type],[isSecure],[comments])
    SELECT  j.[codeType],
            j.[code],
            j.[description],
            j.[type],
            j.[isSecure],
            j.[comments]
    FROM    [dbo].[syscode] j
    WHERE   j.[codeType] = CASE WHEN @codeType = '' THEN j.[codeType] ELSE @codeType END
    AND     j.[code] = CASE WHEN @code = '' THEN j.[code] ELSE @code END
    ORDER BY j.[codeType],j.[code]
  END
END

SELECT  j.[codeType] AS [testCodeType],
        j.[code] AS [testCode],
        j.[description] AS [testDesc],
        j.[type] AS [testType],
        r.[codeType] AS [prodCodeType],
        r.[code] AS [prodCode],
        r.[description] AS [prodDesc],
        r.[type] AS [prodType]
FROM    [taft].[COMPASS_DVLP].[dbo].[syscode] j FULL OUTER JOIN
        [dbo].[syscode] r
ON      r.[codeType] = j.[codeType]
AND     r.[code] = j.[code]
WHERE  (r.[codeType] = CASE WHEN @codeType = '' THEN r.[codeType] ELSE @codeType END
AND     r.[code] = CASE WHEN @code = '' THEN r.[code] ELSE @code END)
OR     (j.[codeType] = CASE WHEN @codeType = '' THEN j.[codeType] ELSE @codeType END
AND     j.[code] = CASE WHEN @code = '' THEN j.[code] ELSE @code END)
AND    (j.[codeType] IS NULL OR r.[codeType] IS NULL)
ORDER BY j.[codeType],j.[code]