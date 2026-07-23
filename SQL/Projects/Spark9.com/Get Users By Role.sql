USE alliant

DECLARE @role VARCHAR(30) = '' -- The userid

IF (@role = '')
BEGIN
  SELECT  [RoleName]
  FROM    [dbo].[aspnet_Roles]
  GROUP BY [RoleName]
END
ELSE
BEGIN
  SELECT a.[UserName]
        ,a.[fullname]
        ,a.[Position]
        ,d.[RoleName]
    FROM [dbo].[t_user] a inner join
         [dbo].[aspnet_Users] b inner join
         [dbo].[aspnet_UsersInRoles] c inner join
         [dbo].[aspnet_Roles] d
      ON d.RoleId = c.RoleId
      ON c.UserId = b.UserId
      ON b.username = a.UserName
    WHERE d.[RoleName] = @role
END