GO

DECLARE @system VARCHAR(50) = 'Audit',
        @field VARCHAR(50) = '',
        @delete BIT = 0

IF (@delete = 1)
BEGIN
  DELETE
    FROM [dbo].[UserFiles]
   WHERE [System] = CASE WHEN @system = '' THEN [System] ELSE @system END
     AND [Field] = CASE WHEN @field = '' THEN [Field] ELSE @field END
END
ELSE
BEGIN
  SELECT *
    FROM [dbo].[UserFiles]
   WHERE [System] = CASE WHEN @system = '' THEN [System] ELSE @system END
     AND [Field] = CASE WHEN @field = '' THEN [Field] ELSE @field END
   ORDER BY [CreatedDate] DESC
END
GO


