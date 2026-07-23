GO

SELECT  i.[apinvID]
INTO    #invoiceTable
FROM    [apinv] i LEFT OUTER JOIN
        [apinvd] id
ON      i.[apinvID] = id.[apinvID]
WHERE   id.[apinvID] IS NULL

SELECT * FROM #invoiceTable

SELECT  RowNum = ROW_NUMBER() OVER(ORDER BY [apinvID]),
        [apinvID]
INTO #temp
FROM #invoiceTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @invoiceID INTEGER,
        @claimID INTEGER,
        @stateID VARCHAR(2),
        @refCategery VARCHAR(1),
        @acct VARCHAR(30),
        @acctName VARCHAR(50),
        @amount DECIMAL(18,2)
        
WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @invoiceID = [apinvID] FROM #temp WHERE [RowNum] = @Iter
  SELECT  @claimID = CONVERT(INTEGER, [refID]),
          @amount = [amount],
          @refCategery = [refCategory]
  FROM    [dbo].[apinv]
  WHERE   [apinvID] = @invoiceID

  SELECT  @stateID = [stateID]
  FROM    [dbo].[claim]
  WHERE   [claimID] = @claimID

  SET @acct = '1-500' + CASE WHEN @refCategery = 'L' THEN '10' ELSE '25' END + '-' + (SELECT RIGHT('00' + CONVERT(VARCHAR, [seq]), 2) FROM [dbo].[state] WHERE [stateID] = @stateID)

  SELECT  @acctName = RTRIM(am.[ACTDESCR])
  FROM    [ANTIC].[dbo].[GL00100] am INNER JOIN
          [ANTIC].[dbo].[GL00105] a
  ON      a.[ACTINDX] = am.[ACTINDX] INNER JOIN
          [dbo].[state] s
  ON      s.[seq] = CONVERT(INTEGER,SUBSTRING(RTRIM(a.[ACTNUMST]),LEN(RTRIM(a.[ACTNUMST]))-1,2))
  AND     s.[active] = 1
  AND     a.[ACTNUMST] = @acct
  ORDER BY a.[ACTNUMST]

  INSERT INTO [dbo].[apinvd]
             ([apinvID]
             ,[seq]
             ,[acct]
             ,[acctName]
             ,[amount])
       VALUES
             (@invoiceID
             ,1
             ,@acct
             ,@acctName
             ,@amount)

  SET @Iter = @Iter + 1
END

DROP TABLE #invoiceTable
DROP TABLE #temp
GO