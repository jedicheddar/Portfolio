DECLARE @user VARCHAR(32) = '',
        @name VARCHAR(100) = '',
        @initials VARCHAR(10) = '',
        @password VARCHAR(32) = '',
        @expire BIT = 0,
        @isTest BIT = 0

DECLARE @index INT = 1

IF (@name = '')
BEGIN
  SELECT @initials=[initials] FROM [dbo].[sysuser] WHERE [uid] = @user
  SELECT @name=[name] FROM [dbo].[sysuser] WHERE [uid] = @user
END
ELSE
BEGIN
  WHILE @index < [dbo].[GetNumEntries] (@name, ' ') + 1
  BEGIN
    SET @initials = @initials + SUBSTRING([dbo].[GetEntry] (@index, @name, ' '), 1, 1)
    SET @index = @index + 1
  END
END

IF (@user <> '')
BEGIN
  UPDATE  [dbo].[sysuser]
  SET     [password] = CASE WHEN @password = '' THEN [password] ELSE @password END,
          [passwordExpired] = @expire,
          [passwordSetDate] = CASE WHEN @expire = 1 THEN DATEADD(MONTH,-4,GETDATE()) ELSE CASE WHEN @isTest = 1 THEN '2900-12-31' ELSE GETDATE() END END,
          [name] = @name,
          [initials] = @initials
  WHERE   [uid] = @user
END

SELECT  [uid],
        CASE WHEN @user <> '' THEN [password] ELSE 'XXX' END AS [password],
        [name],
        [initials],
        [email],
        [role],
        [isActive],
        [createDate],
        [passwordSetDate],
        [passwordExpired],
        [comments]
FROM    [dbo].[sysuser]
WHERE   [uid] = CASE WHEN @user = '' THEN [uid] ELSE @user END