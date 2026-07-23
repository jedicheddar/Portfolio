DECLARE @policyList VARCHAR(MAX) = '',
        @officeID INTEGER = 0,
        @migrate BIT = 0

DECLARE @policyID INTEGER = 0,
        @agent VARCHAR(100) = '',
        @lastOfficeID INTEGER = 0,
        @oldOfficeID INTEGER = 0,
        @validOffice INTEGER = 0,
        @validLimit INTEGER = 0,
        @numPolicy INTEGER = 0,
        @counter INTEGER = 0,
        @countSinceLastOffice INTEGER = 0,
        @pos INTEGER = 0,
        @lastPos INTEGER = 0

CREATE TABLE #validationTable ([policyID] INTEGER, [oldOffice] INTEGER, [newOffice] VARCHAR(MAX))

SELECT @numPolicy = LEN(@policyList) - LEN(REPLACE(@policyList, ',', ''))

WHILE @counter <= @numPolicy
BEGIN
  SELECT @pos = CHARINDEX(',',@policyList, @lastPos)
  IF @pos > 0
    SELECT @policyID = SUBSTRING(@policyList, @lastPos, @pos - @lastPos)
  ELSE
    SELECT @policyID = SUBSTRING(@policyList, @lastPos, (LEN(@policyList) - @lastPos) + 1)
  SET @lastPos = @pos + 1

  SELECT @agent=[agent], @oldOfficeID=[cid] FROM [dbo].[t_policies] WHERE [policyID] = @policyID

  SELECT @validOffice=COUNT(*) FROM [dbo].[t_usercompany] WHERE [username] = @agent AND [cid] = @oldOfficeID

  IF (@validOffice = 1)
  BEGIN
    IF (@lastOfficeID <> @oldOfficeID)
    BEGIN
      SET @lastOfficeID = @oldOfficeID
      SET @countSinceLastOffice = 0
    END
    
    SELECT  @validLimit=(c.[policylimit] - COUNT(p.[policyID]) - (@countSinceLastOffice + 1))
    FROM    [dbo].[t_company] c INNER JOIN
            [dbo].[t_policies] p
    ON      c.[cid] = p.[cid]
    WHERE   c.[cid] = @oldOfficeID
    AND     p.[paid] = 0
    GROUP BY c.[policylimit]

    IF (@validLimit > 0)
    BEGIN
      IF (@migrate = 1)
      BEGIN
        UPDATE  [dbo].[t_policies]
        SET     [cid] = @officeID
        WHERE   [policyID] = @policyID
      END
      ELSE
      BEGIN
        INSERT INTO #validationTable ([policyID],[oldOffice],[newOffice])
        SELECT  [policyID],
                [cid],
                @officeID
        FROM    [dbo].[t_policies]
        WHERE   [policyID] = @policyID
      END
    END
    ELSE
    BEGIN
      INSERT INTO #validationTable ([policyID],[oldOffice],[newOffice])
      SELECT  [policyID],
              [cid],
              'Not enough available policies'
      FROM    [dbo].[t_policies]
      WHERE   [policyID] = @policyID
    END
  END
  ELSE
  BEGIN
    INSERT INTO #validationTable ([policyID],[oldOffice],[newOffice])
    SELECT  [policyID],
            [cid],
            'Invalid office'
    FROM    [dbo].[t_policies]
    WHERE   [policyID] = @policyID
  END
  SET @counter = @counter + 1
  SET @countSinceLastOffice = @countSinceLastOffice + 1
END

SELECT * FROM #validationTable

DROP TABLE #validationTable