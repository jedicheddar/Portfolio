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
ALTER PROCEDURE [dbo].[spDeletePolicyJacket]
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
          @tempFormID INT,
          @active BIT,
          @index INT,
          @maxIndex INT,
          @dbName VARCHAR(30),
          @dbEnv VARCHAR(4),
          @sql NVARCHAR(MAX),
          @parm NVARCHAR(MAX)

  SELECT @formID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname AND [State]=@formstate
  IF (@formID IS NULL)
  BEGIN
    PRINT 'The form is not found in the database. Please check that the form name and state is correct'
    ROLLBACK TRANSACTION
    RETURN 1
  END
  ELSE
  BEGIN
    --check if the form to be deleted is active
    PRINT 'Checking if form [' + CONVERT(VARCHAR(20),@formID) + '] "' + @formName + '" is active'
    SELECT @active=[Active] FROM [dbo].[t_policyforms] WHERE [PFormID]=@formID

    IF (@active = 1)
    BEGIN
      --the form to be deleted is active so update the previously active form
      SELECT @tempFormID=max([PFormID]) FROM [dbo].[t_policyforms] WHERE [FormName]=@formname AND [State]=@formstate AND [Active]=0
      PRINT 'The previously active form is [' + CONVERT(VARCHAR(20),@tempFormID) + '] "' + @formName + '"'

      --update the previous form to be active
      IF (@tempFormID IS NOT NULL)
      BEGIN
        PRINT 'Activating form [' + CONVERT(VARCHAR(20),@tempFormID) + '] "' + @formName + '"'
        UPDATE [dbo].[t_policyforms] SET [Active]=1 WHERE [PFormID]=@tempFormID
      END
    END

    PRINT 'Deleting form [' + CONVERT(VARCHAR(20),@formID) + '] "' + @formName + '"'
    --update the current form to not be active
    DELETE FROM [dbo].[t_policyforms] WHERE [PFormID]=@formID
    PRINT ''
  END
  COMMIT TRANSACTION
END
