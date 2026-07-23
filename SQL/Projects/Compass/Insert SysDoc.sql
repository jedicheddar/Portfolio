USE [COMPASS]

DECLARE @entityType VARCHAR(50) = '',
        @entityID VARCHAR(50) = '',
        @entitySeq INTEGER = 0,
        @objType VARCHAR(50) = '',
        @objID VARCHAR(200) = '',
        @objAttr VARCHAR(200) = ''

INSERT INTO [dbo].[sysdoc] ([entityType] ,[entityID] ,[entitySeq] ,[objType] ,[objID] ,[objAttr] ,[docDate] ,[uid]) VALUES
(
  @entityType,
  @entityID,
  @entitySeq,
  @objType,
  @objID,
  @objAttr,
  GETDATE(),
  'joliver@alliantnational.com'
)