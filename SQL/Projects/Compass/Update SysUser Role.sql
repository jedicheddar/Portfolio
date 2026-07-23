DECLARE @role VARCHAR(200) = '',
        @user VARCHAR(32) = 'joliver@alliantnational.com'

IF (@role <> '' AND @user <> '')
BEGIN
  UPDATE sysuser
  SET    [role] = @role
  WHERE  [uid] = @user

  SELECT  [uid],
          [name],
          [role]
  FROM    [sysuser]
  WHERE   [uid] = @user
END
ELSE
BEGIN
  SELECT  [roles]
  FROM    (
          SELECT  LTRIM(RTRIM(m.n.value('.[1]','varchar(MAX)'))) AS [roles]
          FROM    (
                  SELECT CAST('<XMLRoot><RowData>' + REPLACE([role],',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
                  FROM   [dbo].[sysuser]
                  ) t
          CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)
          ) a
  GROUP BY [roles]
  ORDER BY [roles]

  IF (@user <> '')
  BEGIN
    SELECT  [uid],[role]
    FROM    sysuser
    WHERE   uid = @user
  END
END