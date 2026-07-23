USE [COMPASS]

DECLARE @countyID VARCHAR(MAX) = 'Bexar,Tarrant,Dallas',
        @stateID VARCHAR(10) = 'TX',
        @liability MONEY = 0,
        @effDate DATETIME = NULL

DECLARE @tempCountyID VARCHAR(100),
        @NextString NVARCHAR(100),
        @Pos INTEGER = 0,
        @Str NVARCHAR(MAX),
        @Delimiter NCHAR(1) = ','

IF (@effDate IS NULL)
  SET @effDate = DATEADD(YEAR, -1, GETDATE())

CREATE TABLE #county ([countyID] VARCHAR(100), [description] VARCHAR(MAX))
IF (@countyID = '')
BEGIN
  INSERT INTO #county ([countyID],[description])
  SELECT  [countyID],
          [description]
  FROM    [dbo].[county]
  WHERE   [stateID] = CASE WHEN @stateID = '' THEN [stateID] ELSE @stateID END
END
ELSE
BEGIN
  SET @Str = @countyID + @Delimiter
  SET @Pos = CHARINDEX(@Delimiter, @Str)
  WHILE (@Pos <> 0)
	BEGIN
		SET @NextString = SUBSTRING(@Str,1,@Pos-1)

    INSERT INTO #county ([countyID],[description])
    SELECT  [countyID],
            [description]
    FROM    [dbo].[county]
    WHERE   [stateID] = CASE WHEN @stateID = '' THEN [stateID] ELSE @stateID END
    AND    ([countyID] = @NextString OR [description] = @NextString)

		SET @Str = SUBSTRING(@Str,@Pos+1,LEN(@Str))
		SET @Pos = CHARINDEX(@Delimiter, @Str)
	END
END

CREATE TABLE #policy ([policyID] INTEGER, [fileNumber] VARCHAR(100))
INSERT  INTO #policy ([policyID],[fileNumber])
SELECT  p.[policyID],
        p.[fileNumber]
FROM    [dbo].[policy] p INNER JOIN
        [dbo].[stateform] sf
ON      p.[formID] = sf.[formID]
AND     p.[stateID] = sf.[stateID]
AND    (p.[countyID] IN (SELECT [countyID] FROM #county) OR p.[countyID] IN (SELECT [description] FROM #county))
WHERE   sf.[insuredType] IN ('B','O')
AND     p.[liabilityAmount] > @liability
AND     p.[effDate] > @effDate

DELETE
FROM    #policy
WHERE   [fileNumber] IN
        (
        SELECT  p.[fileNumber]
        FROM    [dbo].[policy] p INNER JOIN
                [dbo].[stateform] sf
        ON      p.[formID] = sf.[formID]
        AND     p.[stateID] = sf.[stateID]
        WHERE   sf.[insuredType] IN ('L')
        )

SELECT  a.[agentID] AS [Agent ID],
        a.[name] AS [Agent Name],
        bf.[fileNumber] AS [File Number],
        sf.[description] AS [Policy Type],
        p.[effDate] AS [Effective Date],
        p.[liabilityAmount] AS [Amount of Policy],
        c.[description] AS [County]
FROM    [dbo].[agent] a INNER JOIN
        [dbo].[batch] b
ON      a.[agentID] = b.[agentID] INNER JOIN
        [dbo].[batchform] bf
ON      b.[batchID] = bf.[batchID] INNER JOIN
        [dbo].[stateform] sf
ON      b.[stateID] = sf.[stateID]
AND     bf.[formID] = sf.[formID] INNER JOIN
        [dbo].[policy] p
ON      bf.[policyID] = p.[policyID] INNER JOIN
        #county c
ON     (p.[countyID] = c.[countyID] OR p.[countyID] = c.[description])
WHERE   bf.[policyID] IN (SELECT [policyID] FROM #policy)
AND     bf.[formType] = 'P'
ORDER BY a.[name],bf.[fileNumber]

DROP TABLE #county
DROP TABLE #policy