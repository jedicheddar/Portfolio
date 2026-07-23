GO
CREATE TABLE #actionTable ([act] varchar(32),[descrip] varchar(80),[program] varchar(60),[isQueueable] bit,[isDest] bit,[name] varchar(50),[htmlEmail] varchar(200),[subject] varchar(100))
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderContentsGet','Get the order contents','order/getordercontents.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderDetailsGet','Get the order details','order/getorderdetails.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderPropertySearch','Search fulfilled and closed orders for the property','order/searchorderproperties.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersListGet','Get orders from a comma-delimited list','order/getordersfromlist.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderModify','Modifies the order','order/modifyorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderHold','Holds an order','order/holdorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderLock','Locks an order','order/lockorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderGet','Get an order','order/getorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderReject','Rejects an order','order/rejectorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderRelease','Release an order from a hold','order/releaseorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderRender','Renders an order','order/renderorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderUnlock','Unlocks a locked order','order/unlockorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderFulfill','Fulfills an order','order/fulfillorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderCancel','Cancels an order','order/cancelorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderClose','Closes an order','order/closeorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('orderReopen','Reopens a closed order','order/reopenorder.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersSearch','Searches the orders based on the criteria','order/searchorders.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersIncompleteReport','Report on the incomplete orders','order/reportincompleteorders.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersUnassignedReport','Report on the unassigned orders','order/reportunassignedorders.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersByAgentReport','Report on the orders by agent','order/reportordersbyagent.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersByStateReport','Report on the orders by state','order/reportordersbystate.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('ordersByAssignmentReport','Report on the orders by assignment','order/reportordersbyassignment.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('qualiaOrderActivity','Entry point for the Qualia API messaging system','qualia/qualiaorderactivity.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('qualiaOrderAccept','Accept the qualia order','qualia/acceptqualiaorderwrapper.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('qualiaOrderDeny','Deny the qualia order','qualia/denyqualiaorderwrapper.p',0,0,'','','')
INSERT INTO #actionTable ([act],[descrip],[program],[isQueueable],[isDest],[name],[htmlEmail],[subject]) VALUES ('qualiaOrderComplete','Complete the qualia order','qualia/completequaliaorderwrapper.p',0,0,'','','')

DELETE FROM [sysaction] WHERE [action] LIKE 'order%' OR [action] LIKE 'qualia%'

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