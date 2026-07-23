GO
/****** Object:  StoredProcedure [dbo].[spAlertTORScore]    Script Date: 09/28/2020 9:38:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spAlertTORScore]
  @agentID VARCHAR(MAX) = '',
  @user VARCHAR(100) = 'compass@alliantnational.com',
  @preview BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  SET ANSI_WARNINGS OFF;
  
  CREATE TABLE #agentTable ([agentID] VARCHAR(30))
  INSERT INTO #agentTable ([agentID])
  SELECT [field] FROM [dbo].[GetEntityFilter] ('Agent', @agentID)
  
  DECLARE @alertID INTEGER = 0,
          -- Used for the preview
          @source VARCHAR(30) = 'QAR',
          @processCode VARCHAR(30) = 'QAR06',
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
    [qarScore] INTEGER,
    [errScore] INTEGER,
	[torScore] INTEGER
  )
  
  --Insert the current scores
  INSERT INTO #scoreTable ([agentID], [qarDate], [qarScore], [errScore], [torScore])
  SELECT  q.[agentID],
          q2.[qarDate],
          ISNULL(q.[score],0) AS 'qarScore',
          ISNULL(s.[score],0) AS 'errScore',
		  ISNULL(q.[score],0) AS 'torScore'
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
  AND     q.[auditFinishDate] = q2.[qarDate] LEFT OUTER JOIN
          [dbo].[qarsection] s
  ON      q.[qarID] = s.[qarID]
  AND     s.[sectionID] = 6
  WHERE   q.[stat] = 'C'
  AND     q.[auditType] = 'T'
  AND     q.[agentID] IN (SELECT [agentID] FROM #agentTable)
               
  IF (@preview = 0)
  BEGIN
    -- TOR Score Alert
    DECLARE cur CURSOR LOCAL FOR
    SELECT  [agentID],
            [torScore],
            [qarDate],
            'The TOR Score for ' + CONVERT(VARCHAR, [qarDate], 101) + ' is ' + [dbo].[FormatNumber] ([torScore], 0)
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
          [dbo].[GetAlertThreshold] (@processCode, [torScore]) AS [threshold],
          [dbo].[GetAlertThresholdRange] (@processCode, [torScore]) AS [thresholdRange],
          [dbo].[GetAlertSeverity] (@processCode, [torScore]) AS [severity],
          [torScore] AS [score],
          [dbo].[GetAlertScoreFormat] (@processCode, [torScore]) AS [scoreDesc],
          [qarDate] AS [effDate],
          [dbo].[GetAlertOwner] (@processCode) AS [owner],
          'The TOR Score for ' + CONVERT(VARCHAR, [qarDate], 101) + ' is ' + [dbo].[FormatNumber] ([torScore], 0) AS [note]
  FROM    #scoreTable

  DROP TABLE #agentTable
  DROP TABLE #scoreTable
END
