DECLARE @state VARCHAR(2) = '' -- Enter a state
       ,@version NCHAR(10) = '' -- Enter the version

SELECT  'dev_alliant' AS 'DB'
       ,*
FROM    dev_alliant.dbo.t_ClosingLetter
WHERE   StateInit = @state
AND     RTRIM(Version) = @version
UNION
SELECT  'alliant_test' AS 'DB'
       ,*
FROM    alliant_test.dbo.t_ClosingLetter
WHERE   StateInit = @state
AND     RTRIM(Version) = @version
UNION
SELECT  'alliant' AS 'DB'
       ,*
FROM    alliant.dbo.t_ClosingLetter
WHERE   StateInit = @state
AND     Version = @version
ORDER BY DB
