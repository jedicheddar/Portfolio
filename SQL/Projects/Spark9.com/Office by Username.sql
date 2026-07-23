USE alliant_test

DECLARE @user VARCHAR(30) = 'apitest' -- The userid

SELECT  b.*
FROM    [dbo].[t_usercompany] a inner join
        [dbo].[Offices] b
     ON a.cid = b.cid
  WHERE a.username = @user