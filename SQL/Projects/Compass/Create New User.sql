USE [COMPASS]
GO

DECLARE @name varchar(200) = '' -- Enter the name


IF (@name <> '')
BEGIN
  DECLARE @uid varchar(100) = dbo.GetEmail(@name),
          @password varchar(100) = dbo.GetPassword(@name),
          @count integer

  SELECT  @count=COUNT(*)
  FROM    [dbo].[sysuser]
  WHERE   [uid]=@uid

  IF (@count = 0)
  BEGIN
    INSERT INTO [dbo].[sysuser]
               ([uid]
               ,[name]
               ,[initials]
               ,[email]
               ,[role]
               ,[password]
               ,[isActive]
               ,[createDate]
               ,[passwordSetDate]
               ,[passwordExpired]
               ,[comments])
         VALUES
               (@uid
               ,@name
               ,dbo.GetInitials(@name)
               ,dbo.GetEmail(@name)
               ,'None'
               ,dbo.GetPassword(@name)
               ,1
               ,GETDATE()
               ,GETDATE()
               ,0
               ,NULL)
  END
  ELSE
  BEGIN
    UPDATE  [dbo].[sysuser]
    SET     [password]=@password
    WHERE   [uid]=@uid
  END

  SELECT  *
  FROM    [dbo].[sysuser]
  WHERE   [uid]=@uid
END
ELSE
BEGIN
  PRINT 'Please enter a name'
END
GO

