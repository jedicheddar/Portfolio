DECLARE @ids VARCHAR(1000) = '',
        @isTest BIT = 1

CREATE TABLE #SignatureOffset
(
  [PformID] INT,
  [SignatureOffset] INT
)

IF (@isTest = 1)
BEGIN
  DECLARE @sql NVARCHAR(2000) = 'SELECT [PFormID],[SignatureOffset] FROM [t_policyforms] WHERE [PFormID] IN (' + @ids + ')'

  INSERT INTO #SignatureOffset
  EXEC sp_executesql @statement = @sql

  SELECT 'INSERT INTO #SignatureOffset VALUES (' + CONVERT(VARCHAR,[PFormID]) + ',' + CONVERT(VARCHAR,[SignatureOffset]) + ')' FROM #SignatureOffset
END
ELSE
BEGIN
  --Paste insert statements here


  UPDATE  pf
  SET     [SignatureOffset] = so.[SignatureOffset]
  FROM    [t_policyforms] pf INNER JOIN
          #SignatureOffset so
  ON      pf.[PFormID] = so.[PFormID]

  SELECT  *
  FROM    [t_policyforms] pf INNER JOIN
          #SignatureOffset so
  ON      pf.[PFormID] = so.[PFormID]

END
DROP TABLE #SignatureOffset