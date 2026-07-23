GO
/****** Object:  StoredProcedure [dbo].[spDeactivatePolicyJacket]    Script Date: 10/21/2015 11:35:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		  John Oliver
-- Create date: 10/20/2015
-- Description:	Used to add a Policy Jacket (PJ)
--              from production and set the previous
--              version of the form to not be
--              active
-- =============================================
ALTER PROCEDURE [dbo].[spActivatePolicyJacket]
	-- Add the parameters for the stored procedure here
	@formName		VARCHAR(200) = NULL,
	@formState  VARCHAR(2)   = NULL
AS
BEGIN
  BEGIN TRANSACTION
  -- SET NOCOUNT ON added to prevent extra result SETs from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

  DECLARE @formID INT,
          @activeFormID INT,
          @latestFormID INT

  SELECT @formID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname AND [State]=@formstate
  IF (@formID IS NULL)
  BEGIN
    PRINT 'The form is not found in the database. Please check that the form name and state is correct'
    ROLLBACK TRANSACTION
    RETURN 1
  END
  ELSE
  BEGIN
    --get the current activated ID
    SELECT @activeFormID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname AND [State]=@formstate and [Active]=1

    --get the last row inserted ID
    SELECT @latestFormID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname AND [State]=@formstate and [Active]=0
        
    PRINT 'Activating form [' + CONVERT(VARCHAR(20),@latestFormID) + '] "' + @formName + '"'
    --update the current form to not be active
    UPDATE [dbo].[t_policyforms] SET [Active]=1 where [PFormID]=@latestFormID

    --update the previous form to be active
    IF (@activeFormID IS NOT NULL)
    BEGIN
      PRINT 'Deactivating form [' + CONVERT(VARCHAR(20),@activeFormID) + '] "' + @formName + '"'
      UPDATE [dbo].[t_policyforms] SET [Active]=0 where [PFormID]=@activeFormID
    END
    PRINT ''
  END
  COMMIT TRANSACTION
END
