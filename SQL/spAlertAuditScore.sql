GO
/****** Object:  StoredProcedure [dbo].[spAlertAuditScore]    Script Date: 4/7/2022 8:39:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spAlertAuditScore]
  @agentID VARCHAR(MAX) = '',
  @user VARCHAR(100) = 'compass@alliantnational.com',
  @preview BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
 
  IF (@agentID = '')
    SET @agentID = 'ALL'

  CREATE TABLE #agentTable ([agentID] VARCHAR(30))
  INSERT INTO #agentTable ([agentID])
  SELECT [field] FROM [dbo].[GetEntityFilter] ('Agent', @agentID)
  
  DECLARE @alertID INTEGER = 0,
          -- Used for the preview
          @source VARCHAR(30) = 'QAR',
          @processCode VARCHAR(30) = 'QAR08',
          @threshold DECIMAL(18,2) = 0,
          @severity INTEGER,
          @effDate DATETIME = NULL,
          @score DECIMAL(18,2) = 0,
          -- Notes for the alert note
          @note VARCHAR(MAX) = ''

  CREATE TABLE #scoreTable 
  (
    [agentID] VARCHAR(20),
    [qarDate] DATETIME,
    [qarGrade] INTEGER
  )
  
  --Insert the current scores
  INSERT INTO #scoreTable ([agentID], [qarDate], [qarGrade])
  SELECT  q.[agentID],
          q2.[qarDate],
          ISNULL(q.[grade],0) AS 'qarScore'
  FROM    [dbo].[qar] q INNER JOIN
          [dbo].[agent] a
  ON      q.[agentID] = a.[agentID] INNER JOIN
          (
          SELECT  [agentID],
                  MAX([auditFinishDate]) AS 'qarDate'
          FROM    [dbo].[qar]
          WHERE   [stat] = 'C'
          GROUP BY [agentID]
          ) q2
  ON      q.[agentID] = q2.[agentID]
  AND     q.[auditFinishDate] = q2.[qarDate] 
  AND     q.[agentID] IN (SELECT [agentID] FROM #agentTable)
   
  IF (@preview = 0)
  BEGIN
    -- Audit Score Alert
    DECLARE cur CURSOR LOCAL FOR
    SELECT  [agentID],
            [qarGrade],
            [qarDate],
            'The Audit Score for ' + CONVERT(VARCHAR, [qarDate], 101) + ' is ' + [dbo].[FormatNumber] ([qarGrade], 0) + '%'
    FROM    #scoreTable

    OPEN cur
    FETCH NEXT FROM cur INTO @agentID, @score, @effDate, @note
    WHILE @@FETCH_STATUS = 0 BEGIN
      EXEC [dbo].[spInsertAlert] @source = @source, 
                                  @processCode = @processCode, 
                                  @user = @user, 
                                  @agentID = @agentID, 
                                  @score = @score, 
                                  @effDate = @effDate,
                                  @note = @note
      FETCH NEXT FROM cur INTO @agentID, @score, @effDate, @note
    END
    CLOSE cur
    DEALLOCATE cur
  END
  
  SELECT  [agentID] AS [agentID],
          @source AS [source],
          @processCode AS [processCode],
          [dbo].[GetAlertThreshold] (@processCode, [qarGrade]) AS [threshold],
          [dbo].[GetAlertThresholdRange] (@processCode, [qarGrade]) AS [thresholdRange],
          [dbo].[GetAlertSeverity] (@processCode, [qarGrade]) AS [severity],
          [qarGrade] AS [score],
          [dbo].[GetAlertScoreFormat] (@processCode, [qarGrade]) AS [scoreDesc],
          [qarDate] AS [effDate],
          [dbo].[GetAlertOwner] (@processCode) AS [owner],
          'The Audit Score for ' + CONVERT(VARCHAR, [qarDate], 101) + ' is ' + [dbo].[FormatNumber] ([qarGrade], 0) + '%' AS [note]
  FROM    #scoreTable

  DROP TABLE #agentTable
  DROP TABLE #scoreTable
END
