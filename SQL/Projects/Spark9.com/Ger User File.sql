USE [alliant_test]
USE [alliant]

DECLARE @system VARCHAR(30) = '',
        @field VARCHAR(30) = '',
        @category VARCHAR(100) = ''

SELECT  *
FROM    [UserFiles]
WHERE   [System] = CASE WHEN @system = '' THEN [System] ELSE @system END
AND     [Field] = CASE WHEN @field = '' THEN [Field] ELSE @field END
AND     [Category] = CASE WHEN @category = '' THEN [Category] ELSE @category END