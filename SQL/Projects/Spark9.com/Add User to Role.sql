USE alliant

DECLARE @role VARCHAR(30) = 'Policies', -- The userid
        @newRole VARCHAR(30) = 'PolicyApi'

declare @cplTable table (username VARCHAR(50),userguid uniqueidentifier)

IF (@role = '')
BEGIN
  SELECT  [RoleName]
  FROM    [dbo].[aspnet_Roles]
  GROUP BY [RoleName]
END
ELSE
BEGIN
  INSERT INTO @cplTable
  SELECT a.[Username],c.[UserID]
    FROM [dbo].[t_user] a inner join
         [dbo].[aspnet_Users] b inner join
         [dbo].[aspnet_UsersInRoles] c inner join
         [dbo].[aspnet_Roles] d
      ON d.RoleId = c.RoleId
      ON c.UserId = b.UserId
      ON b.username = a.UserName
   WHERE d.[RoleName] = @role

  Delete from @cplTable
  where  userguid in (
  SELECT c.[UserID]
    FROM [dbo].[t_user] a inner join
         [dbo].[aspnet_Users] b inner join
         [dbo].[aspnet_UsersInRoles] c inner join
         [dbo].[aspnet_Roles] d
      ON d.RoleId = c.RoleId
      ON c.UserId = b.UserId
      ON b.username = a.UserName
   WHERE d.[RoleName] = @newRole
   )

   --exec [dbo].[aspnet_UsersInRoles_AddUsersToRoles]
   select 'exec [alliant].[dbo].[aspnet_UsersInRoles_AddUsersToRoles] ''/nweb'', ' +
          '''' + [username] + ''', ' +
          '''' + @newRole + ''', ' +
          '''' + convert(varchar,getdate()) + ''''
   from   @cplTable
           
END