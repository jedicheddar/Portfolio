CREATE TABLE [tempdb].[dbo].[SysDest](
	[entityType] [varchar](20) NULL,
	[entityID] [varchar](50) NULL,
	[action] [varchar](32) NULL,
	[destType] [varchar](50) NULL,
	[destName] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

DECLARE @user VARCHAR(50) = ''

IF @user <> ''
BEGIN
  INSERT INTO [tempdb].[dbo].[SysDest] ([entityType],[entityID],[action],[destType],[destName]) VALUES ('A',@user,'auditFinish','E',@user)
  INSERT INTO [tempdb].[dbo].[SysDest] ([entityType],[entityID],[action],[destType],[destName]) VALUES ('A',@user,'auditFinish','S','A')
END

DECLARE @seed INTEGER

SELECT @seed = [seq] FROM [dbo].[syskey] WHERE [type] = 'sysdest'

INSERT INTO [sysdest] ([destID],[entityType],[entityID],[action],[destType],[destName])
SELECT  RANK() OVER (ORDER BY [entityID],[action],[destType],[destName]) + @seed,
        [entityType],
        [entityID],
        [action],
        [destType],
        [destName]
FROM    [tempdb].[dbo].[SysDest]

UPDATE  [dbo].[syskey] 
SET     [seq] = (SELECT COALESCE(MAX([destID]),0) FROM [dbo].[sysdest])
WHERE   [type] = 'sysdest'

SELECT * FROM [dbo].[syskey] WHERE [type] = 'sysdest'

SELECT * FROM [dbo].[sysdest] WHERE [destID] > @seed