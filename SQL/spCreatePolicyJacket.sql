GO
/****** Object:  StoredProcedure [dbo].[spCreatePolicyJacket]    Script Date: 7/21/2022 9:01:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		John Oliver
-- Create date: 10/20/2015
-- Description:	Used to insert or update a 
--              Policy Jacket (PJ) into all three
--              database environments. The
--              production database form is not
--              immediately activated. To activate
--              the production form, use the stored
--              procedure spActivatePolicyJacket and
--              provide the formID listed on the
--              return of this procedure
-- =============================================
ALTER PROCEDURE [dbo].[spCreatePolicyJacket]
	-- Add the parameters for the stored procedure here
	@formName	 VARCHAR(200) = NULL,
	@formState VARCHAR(2)   = NULL,
  @filename  VARCHAR(200) = NULL,
  @formType  VARCHAR(20)  = NULL,
  @weight    INT = 1,
  @pj        BIT = 1,
  @formID    VARCHAR(20) = '',
  @flatten   BIT = 1
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result SETs from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  DECLARE @ID INT = NULL,
          @index INT,
          @maxIndex INT,
          @dbName VARCHAR(30),
          @dbEnv VARCHAR(4),
          @sql NVARCHAR(MAX),
          @parm NVARCHAR(MAX),
          @hasdata BIT = 0,
          @hasduplex BIT = 0,
          @version datetime = CONVERT(VARCHAR(20), GETDATE(), 20),
          @prefix VARCHAR(50),
          @offset INT,
          @isError BIT = 0

  -- validate that the necessary fields are filled out
  IF (@formName IS NULL OR @formName = '')
  BEGIN
    RAISERROR(N'Please enter a form name',10,1)
    SET @isError = 1
  END
  
  IF (@formState IS NULL OR @formState = '')
  BEGIN
    RAISERROR(N'Please enter a form state',10,1)
    SET @isError = 1
  END
  
  IF (@filename IS NULL OR @filename = '')
  BEGIN
    RAISERROR(N'Please enter a filename',10,1)
    SET @isError = 1
  END

  -- return if any errors
  IF (@isError = 1)
  BEGIN
    RETURN 1
  END
  
  BEGIN TRANSACTION
  -- make sure the form and state already exist
  SET @ID = NULL
  SELECT @ID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName] = @formname AND [State] = @formstate
  IF (@ID IS NULL)
  BEGIN
    PRINT 'Inserting the new form on the database'
    SET @offset = 10
  END
  ELSE
  BEGIN
    PRINT 'Replacing the form [' + CONVERT(VARCHAR(20), @formID) + '] "' + @formName + '" with a new form on the database'
    SELECT @prefix=[Prefix], @weight=[Weight], @pj=[PJ], @hasdata=[HasData], @hasduplex=[HasDuplex], @formType=[Type], @formID=[FormId] FROM [dbo].[t_policyforms] WHERE [PFormID] = @ID
    SET @offset = 10
    IF (@formID IS NULL)
      SET @formID = ''
  END

  --insert the new form
  INSERT INTO [dbo].[t_policyforms] ([FormName], [Active], [State], [FileName], [Prefix], [Weight], [PJ], [Version], [HasData], [HasDuplex], [Type], [SignatureOffset], [SignatureIndent], [SignatureDateindent], [Flatten], [FormId]) SELECT  @formname, 0, @formstate, @filename, @prefix, @weight, @pj, @version, @hasdata, @hasduplex, @formType, @offset, 18, 140, @flatten, @formID

  --get the formID of the newly inserted form
  SELECT @ID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname and [State]=@formstate
  PRINT 'The new form ID is [' + CONVERT(VARCHAR(20), @ID) + '] with an active flag of 0'
  PRINT ''
  COMMIT TRANSACTION
END
