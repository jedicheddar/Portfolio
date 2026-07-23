USE [COMPASS]

DECLARE @oldStatCode VARCHAR(30) = '',
        @newStatCode VARCHAR(30) = '',
        @oldFormType VARCHAR(10) = '',
        @newFormType VARCHAR(10) = '',
        @stateID VARCHAR(30) = ''

IF (@oldFormType <> '' AND @newFormType <> '' AND @newStatCode <> '' AND @stateID <> '')
BEGIN
  SELECT  bf.[statCode],
          bf.[formType],
          COUNT(*)
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = @stateID
  AND     bf.[statCode] = @oldStatCode
  AND     bf.[formType] = @oldFormType
  GROUP BY bf.[statCode],bf.[formType]
  UNION ALL
  SELECT  bf.[statCode],
          bf.[formType],
          COUNT(*)
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = @stateID
  AND     bf.[statCode] = @newStatCode
  AND     bf.[formType] = @newFormType
  GROUP BY bf.[statCode],bf.[formType]
  ORDER BY bf.[statCode]

  UPDATE  [batchform]
  SET     [statCode] = @newStatCode, [formType] = @newFormType
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = @stateID
  AND     bf.[statCode] = @oldStatCode
  AND     bf.[formType] = @oldFormType

  SELECT  bf.[statCode],
          bf.[formType],
          COUNT(*)
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = @stateID
  AND     bf.[statCode] = @newStatCode
  AND     bf.[formType] = @newFormType
  GROUP BY bf.[statCode],bf.[formType]
  UNION ALL
  SELECT  bf.[statCode],
          bf.[formType],
          COUNT(*)
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = @stateID
  AND     bf.[statCode] = @oldStatCode
  AND     bf.[formType] = @oldFormType
  GROUP BY bf.[statCode],bf.[formType]
  ORDER BY bf.[statCode]
END
ELSE
BEGIN
  SELECT  b.[stateID],
          bf.[statCode],
          bf.[formType],
          COUNT(*)
  FROM    [batch] b INNER JOIN
          [batchform] bf
  ON      b.[batchID] = bf.[batchID]
  WHERE   b.[stateID] = CASE WHEN @stateID = '' THEN b.[stateID] ELSE @stateID END
  GROUP BY b.[stateID],bf.[statCode],bf.[formType]
  ORDER BY b.[stateID],bf.[statCode]
END
