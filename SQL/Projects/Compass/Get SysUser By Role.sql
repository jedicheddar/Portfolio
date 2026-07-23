/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @role VARCHAR(32) = ''

IF (@role <> '')
  SELECT  [uid],
          [name],
          [initials],
          [email],
          [role],
          [password],
          [isActive],
          [createDate],
          [passwordSetDate],
          [passwordExpired],
          [comments]
  FROM    [dbo].[sysuser]
  WHERE   [role] LIKE '%' + @role + '%'
  ORDER BY [uid]
ELSE
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
