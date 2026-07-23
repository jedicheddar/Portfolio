GO
CREATE TABLE #actionTable ([act] varchar(32),[descrip] varchar(80),[program] varchar(60),[isQueueable] bit,[isDest] bit,[name] varchar(50),[htmlEmail] varchar(200),[subject] varchar(100))
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('','','',0,0,'','','')

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY act)
    ,*
INTO #temp
FROM #actionTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

DECLARE @act varchar(200),
        @descrip varchar(200),
        @program varchar(200), 
        @email varchar(100), 
        @emailType varchar(20),
        @isQueueable bit,
        @isDest bit,
        @name varchar(100),
        @htmlEmail varchar(200),
        @subject varchar(200)

WHILE @Iter <= @MaxRownum
BEGIN

  select @act=[act],@descrip=[descrip],@program=[program],@isQueueable=[isQueueable],@isDest=[isDest],@name=[name],@htmlEmail=[htmlEmail],@subject=[subject],@email=CASE WHEN [act] LIKE '%cron%' THEN 'alerts@alliantnational.com' ELSE '' END from #temp where RowNum = @Iter
  IF (@email <> '')
    SET @emailType = 'F'
  ELSE
    SET @emailType = 'N'  
  
  IF (@act <> '')
  BEGIN
    INSERT INTO [sysaction] ([action],[description],[progExec],[isActive],[isAnonymous],[isSecure],[isLog],[isAudit],[roles],[userids],[addrs],[createDate],[emails],[emailSuccess],[emailFailure],[isEventsEnabled],[comments],[isQueueable],[isDestination],[name],[htmlEmail],[subject])
    VALUES (@act,@descrip,@program,1,0,1,1,0,'*','*','*',GETDATE(),@emailType,'',@email,1,'',@isQueueable,@isDest,@name,@htmlEmail,@subject)
  END
    
  SET @Iter = @Iter + 1
END

SELECT * FROM [dbo].[sysaction] WHERE [action] in (SELECT [act] FROM #actionTable)

DROP TABLE #temp
DROP TABLE #actionTable

GO