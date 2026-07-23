USE [COMPASS]
GO

DECLARE @state varchar(2) = ''
       ,@tempCounty varchar(50) = ''
       ,@tempContact varchar(50) = ''

DECLARE @active bit = 0
       ,@appDate datetime = ''
       ,@license varchar(50) = ''
       ,@licEffDate datetime = ''
       ,@licExpDate datetime = ''
       ,@cancelDate datetime = ''
       ,@lastAuditDate datetime = ''
       ,@name varchar(80) = ''
       ,@addr1 varchar(80) = ''
       ,@addr2 varchar(80) = ''
       ,@addr3 varchar(80) = ''
       ,@addr4 varchar(80) = ''
       ,@city varchar(50) = ''
       ,@county varchar(50) = ''
       ,@zip varchar(20) = ''
       ,@contact varchar(60) = ''
       ,@phone varchar(40) = ''
       ,@fax varchar(40) = ''
       ,@email varchar(100) = ''
       ,@website varchar(50) = ''
       ,@comments varchar(max) = ''
       ,@externalApproval bit = 0

IF (@state <> '')
BEGIN
  -- Set the variables to NULL if they are blank
  IF (@appDate = '')
  BEGIN
    SET @appDate = NULL
  END
  IF (@license = '')
  BEGIN
    SET @license = NULL
  END
  IF (@licEffDate = '')
  BEGIN
    SET @licEffDate = NULL
  END
  IF (@licExpDate = '')
  BEGIN
    SET @licExpDate = NULL
  END
  IF (@licExpDate = '')
  BEGIN
    SET @licExpDate = NULL
  END
  IF (@cancelDate = '')
  BEGIN
    SET @cancelDate = NULL
  END
  IF (@lastAuditDate = '')
  BEGIN
    SET @lastAuditDate = NULL
  END
  IF (@name = '')
  BEGIN
	  SET @name = NULL
  END
  IF (@addr1 = '')
  BEGIN
	  SET @addr1 = NULL
  END
  IF (@addr2 = '')
  BEGIN
	  SET @addr2 = NULL
  END
  IF (@addr3 = '')
  BEGIN
	  SET @addr3 = NULL
  END
  IF (@addr4 = '')
  BEGIN
	  SET @addr4 = NULL
  END
  IF (@city = '')
  BEGIN
	  SET @city = NULL
  END
  IF (@zip = '')
  BEGIN
	  SET @zip = NULL
  END
  IF (@contact = '')
  BEGIN
	  SET @contact = NULL
  END
  IF (@phone = '')
  BEGIN
	  SET @phone = NULL
  END
  IF (@fax = '')
  BEGIN
	  SET @fax = NULL
  END
  IF (@email = '')
  BEGIN
	  SET @email = NULL
  END
  IF (@website = '')
  BEGIN
	  SET @website = NULL
  END
  IF (@comments = '')
  BEGIN
	  SET @comments = NULL
  END

  SELECT @tempCounty=[countyID] FROM [dbo].[county] WHERE [description]=@county

  IF (@tempCounty <> '')
  BEGIN
    SET @county = @tempCounty
  END

  IF (@contact IS NOT NULL AND charindex('%',@contact) = 0)
  BEGIN
    SET @tempContact = @contact + '%'

    SELECT  @contact=[uid]
    FROM    COMPASS.dbo.sysuser
    WHERE   name LIKE @tempContact
  END

  UPDATE [dbo].[state]
     SET [active] = @active
        ,[appDate] = @appDate
        ,[license] = @license
        ,[licEffDate] = @licEffDate
        ,[licExpDate] = @licExpDate
        ,[cancelDate] = @cancelDate
        ,[lastAuditDate] = @lastAuditDate
        ,[name] = @name
        ,[addr1] = @addr1
        ,[addr2] = @addr2
        ,[addr3] = @addr3
        ,[addr4] = @addr4
        ,[city] = @city
        ,[county] = @county
        ,[state] = @state
        ,[zip] = @zip
        ,[contact] = @contact
        ,[phone] = @phone
        ,[fax] = @fax
        ,[email] = @email
        ,[website] = @website
        ,[comments] = @comments
        ,[externalApproval] = @externalApproval
   WHERE [stateID] = @state

   SELECT * FROM [dbo].[state] WHERE [stateID] = @state
END
ELSE
BEGIN
  PRINT 'Please add a state'
END
