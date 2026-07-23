/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @oldAction as varchar(32) = ''
       ,@newAction as varchar(32) = ''

IF (@oldAction <> '' and @newAction <> '')
BEGIN
  UPDATE  [dbo].[sysaction]
  SET     [action] = @newAction
  WHERE   [action] = @oldAction

  SELECT * FROM [dbo].[sysaction] WHERE [action] = @newAction
END
ELSE
BEGIN
  SELECT  [action]
         ,[description]
         ,[progExec]
  FROM    [sysaction]
  ORDER BY [action]
END