DECLARE @code VARCHAR(10) = 'CLM01',
        @agentID VARCHAR(10) = '',
        @setSeverity INTEGER = 1,
        @score DECIMAL(18,2) = 0,
        @autoClose BIT = 1,
        @addNote BIT = 0

DECLARE @source VARCHAR(10) = '',
        @severityIndex INTEGER = 0,
        @effDate DATETIME = NULL,
        @status VARCHAR(100) = '',
        @alertID INTEGER = 0

SET @effDate = GETDATE()

IF (@code != '' AND @code != 'AP01')
BEGIN
  IF (@agentID = '')
    SELECT TOP 1 @agentID = [agentID] FROM [dbo].[agent] ORDER BY [name]

  IF (@setSeverity > 0 AND @score = 0)
  BEGIN
    IF (@setSeverity = 1)
      SET @severityIndex = 2
    IF (@setSeverity = 2)
      SET @severityIndex = 1
    SELECT @score = CONVERT(DECIMAL(18,2),[dbo].[GetEntry] (@severityIndex, [objValue], ',')) FROM [dbo].[sysprop] WHERE [appCode] = 'AMD' AND [objAction] = 'Alert' AND [objProperty] = 'Threshold' AND [objID] = @code
  END

  SET @source = SUBSTRING(@code,0,CHARINDEX('0',@code,0))

  EXEC [dbo].[spInsertAlert] @source = @source,@processCode = @code,@user = 'joliver@alliantnational.com',@agentID = @agentID,@score = @score,@effDate = @effDate
  
  SELECT  @status = CASE 
                      WHEN [stat] = 'O' AND @autoClose = 1 THEN 'Updated to closed due to flag' 
                      WHEN [stat] = 'O' AND @autoClose = 0 THEN 'No Update'
                      WHEN [stat] = 'C'                    THEN 'Closed automatically'
                    END
  FROM    [dbo].[alert]
  WHERE   [agentID] = @agentID
  AND     [processCode] = @code

  IF (@addNote = 1)
  BEGIN
    SELECT  @alertID = [alertID]
    FROM    [dbo].[alert]
    WHERE   [agentID] = @agentID
    AND     [processCode] = @code
    AND     [active] = 1

    EXEC [dbo].[spInsertAlertNote] @alertID = @alertID, @user = 'joliver@alliantnational.com', @description = 'This is a note for testing'
  END

  IF (@autoClose = 1)
    UPDATE  [dbo].[alert]
    SET     [stat] = 'C',
            [dateClosed] = GETDATE(),
            [closedBy] = 'joliver@alliantnational.com'
    WHERE   [agentID] = @agentID
    AND     [processCode] = @code
    AND     [active] = 1
    AND     [stat] = 'O'

  SELECT  a.[alertID],
          a.[agentID],
          a.[source],
          a.[processCode],
          ISNULL(c.[description],'') AS [description],
          a.[threshold],
          a.[score],
          a.[description],
          a.[severity],
          a.[dateCreated],
          a.[createdBy],
          a.[dateClosed],
          a.[closedBy],
          a.[effDate],
          a.[stat],
          a.[active],
          (SELECT COUNT(*) FROM [dbo].[alertnote] WHERE [alertID] = a.[alertID]) AS [notes],
          CASE WHEN [active] = 1 THEN @status ELSE '' END AS [status]
  FROM    [dbo].[alert] a LEFT OUTER JOIN
          [dbo].[syscode] c
  ON      a.[processCode] = c.[code]
  WHERE   a.[agentID] = @agentID
  AND     a.[processCode] = @code
  ORDER BY [agentID], [alertID]
END
ELSE
BEGIN
  SELECT  prop.[objID],
          code.[description],
          prop.[objValue],
          [dbo].[GetEntry] (1, [objDesc], ',') AS [GreaterThan],
          [dbo].[GetEntry] (2, [objDesc], ',') AS [AutoClose],
          [objRef] AS [noteToClose]
  FROM    [dbo].[sysprop] prop INNER JOIN
          [dbo].[syscode] code
  ON      prop.[objID] = code.[code]
  AND     prop.[appCode] = 'AMD'
  AND     prop.[objAction] = 'Alert'
  AND     prop.[objProperty] = 'Threshold'
END