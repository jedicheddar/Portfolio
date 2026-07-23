GO

UPDATE [dbo].[t_policies]
   SET [void] = 1
 WHERE [agent] like 'apitest%'
   AND [void] = 0
GO


