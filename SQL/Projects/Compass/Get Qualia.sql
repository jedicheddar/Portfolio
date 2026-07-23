DECLARE @qualiaID AS VARCHAR(30) = '',
        @activitySeq AS INT = 6,
        @delete AS BIT = 0

IF (@delete = 0)
BEGIN
  SELECT  *
  FROM    [qualia]
  WHERE   [qualiaID] = CASE WHEN @qualiaID = '' THEN [qualiaID] ELSE @qualiaID END

  IF (@qualiaID <> '')
  BEGIN
    SELECT  *
    FROM    [qualiaactivity]
    WHERE   [qualiaID] = @qualiaID
  END
END
ELSE
BEGIN
  IF (@qualiaID <> '')
  BEGIN
    IF (@activitySeq = 0)
    BEGIN
      DELETE FROM [qualia] WHERE [qualiaID] = @qualiaID
    END
    DELETE FROM [qualiaactivity] WHERE [qualiaID] = @qualiaID AND [seq] = CASE WHEN @activitySeq = 0 THEN [seq] ELSE @activitySeq END

    SELECT  *
    FROM    [qualia]
    WHERE   [qualiaID] = @qualiaID

    SELECT  *
    FROM    [qualiaactivity]
    WHERE   [qualiaID] = @qualiaID
  END
  ELSE
    PRINT 'Please add the Qualia ID'
END