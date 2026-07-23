USE alliant

DECLARE @user VARCHAR(30) = '%Aimee Anderson%' -- The userid

SELECT a.[UserName]
      ,a.[fullname]
      ,a.[Position]
      ,a.[phone]
      ,a.[fax]
      ,d.[RoleName]
  FROM [dbo].[t_user] a inner join
       [dbo].[aspnet_Users] b inner join
       [dbo].[aspnet_UsersInRoles] c inner join
       [dbo].[aspnet_Roles] d
    on d.RoleId = c.RoleId
    on c.UserId = b.UserId
    on b.username = a.UserName
  where a.[fullname] like @user