GO
/****** Object:  StoredProcedure [dbo].[spAlertTORScoreDrop]    Script Date: 7/5/2021 9:52:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[spAlertTORScoreDrop]
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
          @processCode VARCHAR(30) = 'QAR07',
          @effDate DATETIME = NULL,
          @score DECIMAL(18,2) = 0,
          -- Notes for the alert note
          @note VARCHAR(MAX) = ''
          
  CREATE TABLE #scoreTable 
  (
    [agentID] VARCHAR(20),
    [qarDate] DATETIME,
    [torScore] INTEGER,
    [prevQarDate] DATETIME,
    [prevTorScore] INTEGER,
    [torScoreDrop] INTEGER
  )

  --Insert the current scores
  INSERT INTO #scoreTable ([agentID], [qarDate], [torScore], [prevTorScore])
  SELECT  q.[agentID],
          q2.[qarDate],
          ISNULL(q.[score],0) AS [torScore],
          0
  FROM    [dbo].[qar] q INNER JOIN
          [dbo].[agent] a
  ON      q.[agentID] = a.[agentID] INNER JOIN
          (
          SELECT  [agentID],
                  MAX([auditFinishDate]) AS [qarDate]
          FROM    [dbo].[qar]
          WHERE   [stat] = 'C'
          AND     [auditType] = 'T'
          GROUP BY [agentID]
          ) q2
  ON      q.[agentID] = q2.[agentID]
  AND     q.[auditFinishDate] = q2.[qarDate] 
  AND     q.[stat] = 'C'
  AND     q.[agentID] IN (SELECT [agentID] FROM #agentTable)

  --Insert the previous scores
  MERGE INTO #scoreTable score
  USING   (
          SELECT  q.[agentID],
                  q2.[qarDate],
                  ISNULL(q.[score],0) AS [torScore]
          FROM    [dbo].[qar] q INNER JOIN
                  (
                  SELECT  [agentID],
                          MAX([auditFinishDate]) AS [qarDate]
                  FROM    [dbo].[qar] q
                  WHERE   [auditFinishDate] != (SELECT MAX([auditFinishDate]) FROM [dbo].[qar] WHERE [agentID] = q.[agentID])
				  AND     [auditType] = 'T'						   
                  GROUP BY [agentID]
                  ) q2
          ON      q.[agentID] = q2.[agentID]
          AND     q.[auditFinishDate] = q2.[qarDate] 
                  ) prev
  ON      score.[agentID] = prev.[agentID]
  WHEN MATCHED THEN
  UPDATE SET [prevQarDate] = prev.[qarDate],
             [prevTorScore] = prev.[torScore],
             [torScoreDrop] = prev.[torScore] - score.[torScore];
             
  UPDATE  #scoreTable
  SET     [torScoreDrop] = 0
  WHERE   [torScoreDrop] < 0
  OR      [torScoreDrop] IS NULL

  IF (@preview = 0)
  BEGIN
    -- TOR Score Drop
    DECLARE cur CURSOR LOCAL FOR
    SELECT  [agentID],
            ISNULL([torScoreDrop],0),
            [qarDate],
            'The calculation is Last Years TOR Score (' + [dbo].[FormatNumber] ([prevTorScore], 0) + ') - Current Years TOR Score (' + [dbo].[FormatNumber] ([torScore], 0) + ')'
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
          [dbo].[GetAlertThreshold] (@processCode, [torScoreDrop]) AS [threshold],
          [dbo].[GetAlertThresholdRange] (@processCode, [torScoreDrop]) AS [thresholdRange],
          [dbo].[GetAlertSeverity] (@processCode, [torScoreDrop]) AS [severity],
          [torScoreDrop] AS [score],
          [dbo].[GetAlertScoreFormat] (@processCode, [torScoreDrop]) AS [scoreDesc],
          [qarDate] AS [effDate],
          [dbo].[GetAlertOwner] (@processCode) AS [owner],
           'The calculation is Last Years TOR Score (' + [dbo].[FormatNumber] ([prevTorScore], 0) + ') - Current Years TOR Score (' + [dbo].[FormatNumber] ([torScore], 0) + ')' AS [note]
  FROM    #scoreTable

  DROP TABLE #agentTable
  DROP TABLE #scoreTable
END
