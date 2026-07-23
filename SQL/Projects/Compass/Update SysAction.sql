/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @action VARCHAR(32) = '',
        @roles VARCHAR(200) = '',
        @userids VARCHAR(200) = '',
        @name VARCHAR(100) = '',
        @isActive BIT = 1,
        @isSecure BIT = 1,
        @isLog BIT = 1,
        @isEvent BIT = 1,
        @emailFailure VARCHAR(100) = '',
        @emailSuccess VARCHAR(100) = '',
        @isDestination BIT = 0,
        @isQueueable BIT = 0,
        @html VARCHAR(100) = '',
        @subject VARCHAR(100) = '',
        @update BIT = 0

DECLARE @emails VARCHAR(10)

SELECT  @emails = 
        CASE
          WHEN @emailFailure <> '' AND @emailSuccess <> '' THEN 'B'
          WHEN @emailFailure <> '' AND @emailSuccess =  '' THEN 'F'
          WHEN @emailFailure =  '' AND @emailSuccess <> '' THEN 'S'
          WHEN @emailFailure =  '' AND @emailSuccess =  '' THEN 'N'
        END

IF (@action = '')
BEGIN
  SELECT * FROM [sysaction] ORDER BY [action]

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
  RETURN
END

IF (@roles = '')
  SET @roles = '*'
ELSE
BEGIN
  IF (@roles <> '!*')
    SET @roles = @roles + ',!*'
  IF (@userids = '' AND @userids != '*')
    SET @userids = '!*'
END

IF (@userids = '')
  SET @userids = '*'
ELSE
BEGIN
  IF (@userids != '!*')
    SET @userids = @userids + ',!*'
END

SELECT * FROM [dbo].[sysaction] WHERE [action] LIKE '%' + @action + '%'

IF (@update = 1)
  UPDATE  [dbo].[sysaction]
  SET     [roles] = @roles,
          [userids] = @userids,
          [isActive] = @isActive,
          [isAnonymous] = ~@isSecure,
          [isSecure] = @isSecure,
          [isLog] = @isLog,
          [isEventsEnabled] = @isEvent,
          [emailFailure] = CASE WHEN @emailFailure = '' THEN [emailFailure] ELSE @emailFailure END,
          [emailSuccess] = CASE WHEN @emailSuccess = '' THEN [emailSuccess] ELSE @emailSuccess END,
          [emails] = @emails,
          [comments] = 'Updated on ' + CONVERT(VARCHAR,GETDATE(),120) + ' by joliver@alliantnational.com',
          [isDestination] = @isDestination,
          [isQueueable] = @isQueueable,
          [name] = @name,
          [htmlEmail] = @html,
          [subject] = @subject
  WHERE   [action] LIKE '%' + @action + '%'

SELECT * FROM [dbo].[sysaction] WHERE [action] LIKE '%' + @action + '%'