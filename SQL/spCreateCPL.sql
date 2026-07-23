GO
/****** Object:  StoredProcedure [dbo].[spCreateCPL]    Script Date: 7/21/2022 9:01:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  John Oliver
-- Create date: 12/17/2015
-- Description:	Creates a new CPL
-- =============================================
ALTER PROCEDURE [dbo].[spCreateCPL]
	-- Add the parameters for the stored procedure here
	@state        VARCHAR(2)   = NULL,
  @expiration   INTEGER      = 0,
  @type         VARCHAR(100) = NULL,
  @agentSpec    BIT          = 0,
  @ALTAFooter   BIT          = 1,
  @footerLabel  VARCHAR(200) = NULL,
  @footerCopy   VARCHAR(200) = NULL,
  @footerDesc   VARCHAR(200) = NULL,
  @fontSize     INT          = 8,
  @formID       VARCHAR(20)  = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  DECLARE @stateName VARCHAR(50),
          @stateTrim VARCHAR(50),
          @letter VARCHAR(50),
          @version NCHAR(10),
          @descrip VARCHAR(50),
          @sellerInfo BIT = 0,
          @index INT = 0,
          @maxIndex INT,
          @dbName VARCHAR(30),
          @dbEnv VARCHAR(4),
          @sql NVARCHAR(MAX),
          @parm NVARCHAR(MAX),
          @isError BIT = 0,
          @tempType VARCHAR(20),
          @tempVersion INT,
          @pos INT = 1,
          @lastPos INT = 1,
          @strLen INT

  --validate that the necessary fields are filled out
  IF (@state IS NULL OR @state = '')
  BEGIN
    RAISERROR(N'Please enter a state',10,1)
    SET @isError = 1
  END
  
  IF (@footerLabel IS NULL OR @footerLabel = '')
  BEGIN
    RAISERROR(N'Please enter a footer',10,1)
    SET @isError = 1
  END
  
  IF (@footerCopy IS NULL OR @footerCopy = '')
  BEGIN
    RAISERROR(N'Please enter a footer copyright',10,1)
    SET @isError = 1
  END

  SELECT @stateName=[state_name] FROM dbo.t_states WHERE [state_abbr]=@state
  IF (@stateName = NULL)
  BEGIN
    RAISERROR(N'Invalid state',10,1)
    SET @isError = 1
  END

  --return if any errors
  IF (@isError = 1)
  BEGIN
    RETURN 1
  END

  --set the state
  SET @stateTrim = replace(@stateName,' ','')

  --we need to get the full string length to decide the length of the last segment
  SET @strLen = LEN(@type)

  BEGIN TRANSACTION
  WHILE @pos <> 0
  BEGIN
    SET @pos = CHARINDEX(',',@type,@lastPos)
    IF (@pos > 0)
    BEGIN
      SET @tempType = SUBSTRING(@type,@lastPos,@pos-@lastPos)
      SET @lastPos = @pos + 1
    END
    ELSE
    BEGIN
      SET @tempType = SUBSTRING(@type,@lastPos,@strLen-@lastPos+1)
    END

    --set the version
    SELECT @version=MAX(CONVERT(INTEGER, [Version]) + 1) FROM [dbo].[t_ClosingLetter] WHERE [StateInit] = @state AND [CPLType] = @tempType
    IF @version IS NULL
      SET @version = 1
    
    -- Get the formID if available
    SET @tempVersion = @version - 1
    SELECT @formID = [FormId] FROM [dbo].[t_ClosingLetter] WHERE [StateInit] = @state AND [Version] = @tempVersion AND [CPLType] = @tempType
    IF (@formID IS NULL)
      SET @formID = ''

    -- Set the description
    SET @descrip = @tempType + ' Closing Letter'

    -- Set the lender letter name
    SET @letter = @stateTrim + rtrim(convert(varchar, @version))

    -- Set the seller letter name
    IF (@tempType = 'Seller')
    BEGIN
      SET @sellerInfo=1
      SET @letter = @stateTrim + 'Seller' + rtrim(convert(varchar, @version))
    END

    -- Set the buyer letter name
    IF (@tempType = 'Buyer')
      SET @letter = @stateTrim + 'Buyer' + rtrim(convert(varchar, @version))

    --insert the CPLTemplate
    PRINT 'Inserting a ' + @tempType + ' CPL Template for ' + @stateName + ' that is inactive'
    INSERT INTO [dbo].[t_ClosingLetter] ([StateInit],[StateName],[StateTrim],[Letter],[Version],[Description],[Active],[SellerInfo],[Expiration],[CPLType],[AgentSpecifier],[ALTAFooter],[FooterLabel],[FooterCopyright],[FooterDescription],[FontSize],[Signature],[FormId]) 
    SELECT @state,@stateName,@stateTrim,@letter,@version,@descrip,0,@sellerInfo,@expiration,@tempType,@agentSpec,@ALTAFooter,@footerLabel,@footerCopy,@footerDesc,@fontSize,'dcoffie.png',@formID

  END
  PRINT ''
  COMMIT TRANSACTION
END
