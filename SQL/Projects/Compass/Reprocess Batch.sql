USE [COMPASS]
GO

DECLARE @batchID int = 0,
        @policyID int = 0,
        @cnt int = 0

IF (@batchID > 0)
BEGIN
  SELECT @cnt=COUNT([batchID]) FROM [dbo].[batchform] WHERE [batchID] = @batchID AND [policyID] = @policyID

  IF (@cnt > 0)
  BEGIN
    SELECT 'Before',[reprocess] FROM [dbo].[batchform] WHERE [batchID] = @batchID AND [policyID] = @policyID

    UPDATE [dbo].[batchform]
       SET [reprocess] = 1
     WHERE [batchID] = @batchID
       AND [policyID] = @policyID

    SELECT 'After',[reprocess] FROM [dbo].[batchform] WHERE [batchID] = @batchID AND [policyID] = @policyID
  END
  ELSE
  BEGIN
    PRINT 'Batch and policy are invalid'
  END
END
ELSE
BEGIN
  PRINT 'Please enter a batch and policy ID'
END


