USE [COMPASS]

CREATE TABLE #attrTable ([descrip] VARCHAR(200))
INSERT INTO #attrTable VALUES ('')

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY [descrip])
    ,*
INTO #temp
FROM #attrTable

DECLARE @MaxRownum INT,
        @Iter INT,
        @code VARCHAR(20)
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT  @code='CA' + CONVERT(VARCHAR,MAX(CONVERT(INTEGER,SUBSTRING([code],3,3)+1)))
  FROM    [dbo].[syscode]
  WHERE   [codeType] = 'ClaimAttribute'
  AND     [code] LIKE 'CA%'

  INSERT INTO [dbo].[syscode]
  SELECT  'ClaimAttribute',
          @code,
          [descrip],
          ''
  FROM    #temp
  WHERE   [RowNum] = @Iter
  AND     [descrip] <> ''
    
  SET @Iter = @Iter + 1
END

SELECT  *
FROM    [dbo].[syscode]
WHERE   [codeType] = 'ClaimAttribute'
ORDER BY [code]

DROP TABLE #attrTable
DROP TABLE #temp