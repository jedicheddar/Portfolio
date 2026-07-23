DECLARE @orderID VARCHAR(30) = ''

IF @orderID = ''
  EXEC [dbo].[spSearchOrder]
ELSE
BEGIN
  EXEC [dbo].[spGetOrder] @orderID = @orderID
  EXEC [dbo].[spGetOrderProperty] @orderID = @orderID
  EXEC [dbo].[spGetOrderPerson] @orderID = @orderID
  EXEC [dbo].[spGetOrderNotes] @orderID = @orderID
  EXEC [dbo].[spGetOrderCode] @orderID = @orderID
END