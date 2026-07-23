USE COMPASS

SET ANSI_WARNINGS OFF

DECLARE @update BIT = 0

DECLARE @agentID VARCHAR(20) = '',
        @year INTEGER = 0,
        @month1 DECIMAL(18,2) = 0,
        @month2 DECIMAL(18,2) = 0,
        @month3 DECIMAL(18,2) = 0,
        @month4 DECIMAL(18,2) = 0,
        @month5 DECIMAL(18,2) = 0,
        @month6 DECIMAL(18,2) = 0,
        @month7 DECIMAL(18,2) = 0,
        @month8 DECIMAL(18,2) = 0,
        @month9 DECIMAL(18,2) = 0,
        @month10 DECIMAL(18,2) = 0,
        @month11 DECIMAL(18,2) = 0,
        @month12 DECIMAL(18,2) = 0

CREATE TABLE #compareTable
(
  [type] VARCHAR(20),
  [agentID] VARCHAR(20),
  [year] INTEGER,
  [batch1] DECIMAL(18,2),
  [batch2] DECIMAL(18,2),
  [batch3] DECIMAL(18,2),
  [batch4] DECIMAL(18,2),
  [batch5] DECIMAL(18,2),
  [batch6] DECIMAL(18,2),
  [batch7] DECIMAL(18,2),
  [batch8] DECIMAL(18,2),
  [batch9] DECIMAL(18,2),
  [batch10] DECIMAL(18,2),
  [batch11] DECIMAL(18,2),
  [batch12] DECIMAL(18,2),
  [activity1] DECIMAL(18,2),
  [activity2] DECIMAL(18,2),
  [activity3] DECIMAL(18,2),
  [activity4] DECIMAL(18,2),
  [activity5] DECIMAL(18,2),
  [activity6] DECIMAL(18,2),
  [activity7] DECIMAL(18,2),
  [activity8] DECIMAL(18,2),
  [activity9] DECIMAL(18,2),
  [activity10] DECIMAL(18,2),
  [activity11] DECIMAL(18,2),
  [activity12] DECIMAL(18,2),
  [diff1] DECIMAL(18,2),
  [diff2] DECIMAL(18,2),
  [diff3] DECIMAL(18,2),
  [diff4] DECIMAL(18,2),
  [diff5] DECIMAL(18,2),
  [diff6] DECIMAL(18,2),
  [diff7] DECIMAL(18,2),
  [diff8] DECIMAL(18,2),
  [diff9] DECIMAL(18,2),
  [diff10] DECIMAL(18,2),
  [diff11] DECIMAL(18,2),
  [diff12] DECIMAL(18,2)
)

INSERT INTO #compareTable ([type],[agentID],[year],[batch1],[batch2],[batch3],[batch4],[batch5],[batch6],[batch7],[batch8],[batch9],[batch10],[batch11],[batch12],[activity1],[activity2],[activity3],[activity4],[activity5],[activity6],[activity7],[activity8],[activity9],[activity10],[activity11],[activity12],[diff1],[diff2],[diff3],[diff4],[diff5],[diff6],[diff7],[diff8],[diff9],[diff10],[diff11],[diff12])
SELECT  a.[category],
        a.[agentID],
        a.[year],
        SUM(b.[month1])  AS [batch1],
        SUM(b.[month2])  AS [batch2],
        SUM(b.[month3])  AS [batch3],
        SUM(b.[month4])  AS [batch4],
        SUM(b.[month5])  AS [batch5],
        SUM(b.[month6])  AS [batch6],
        SUM(b.[month7])  AS [batch7],
        SUM(b.[month8])  AS [batch8],
        SUM(b.[month9])  AS [batch9],
        SUM(b.[month10]) AS [batch10],
        SUM(b.[month11]) AS [batch11],
        SUM(b.[month12]) AS [batch12],
        SUM(a.[month1])  AS [activity1],
        SUM(a.[month2])  AS [activity2],
        SUM(a.[month3])  AS [activity3],
        SUM(a.[month4])  AS [activity4],
        SUM(a.[month5])  AS [activity5],
        SUM(a.[month6])  AS [activity6],
        SUM(a.[month7])  AS [activity7],
        SUM(a.[month8])  AS [activity8],
        SUM(a.[month9])  AS [activity9],
        SUM(a.[month10]) AS [activity10],
        SUM(a.[month11]) AS [activity11],
        SUM(a.[month12]) AS [activity12],
        SUM(b.[month1]  - a.[month1])  AS [1],
        SUM(b.[month2]  - a.[month2])  AS [2],
        SUM(b.[month3]  - a.[month3])  AS [3],
        SUM(b.[month4]  - a.[month4])  AS [4],
        SUM(b.[month5]  - a.[month5])  AS [5],
        SUM(b.[month6]  - a.[month6])  AS [6],
        SUM(b.[month7]  - a.[month7])  AS [7],
        SUM(b.[month8]  - a.[month8])  AS [8],
        SUM(b.[month9]  - a.[month9])  AS [9],
        SUM(b.[month10] - a.[month10]) AS [10],
        SUM(b.[month11] - a.[month11]) AS [11],
        SUM(b.[month12] - a.[month12]) AS [12]
FROM    (
        SELECT  [category],
                [agentID],
                [year],
                [month1],
                [month2],
                [month3],
                [month4],
                [month5],
                [month6],
                [month7],
                [month8],
                [month9],
                [month10],
                [month11],
                [month12]
        FROM    (
                SELECT  [category],
                        [agentID],
                        [year],
                        [month1],
                        [month2],
                        [month3],
                        [month4],
                        [month5],
                        [month6],
                        [month7],
                        [month8],
                        [month9],
                        [month10],
                        [month11],
                        [month12]
                FROM    [dbo].[agentactivity] a
                WHERE   [type] = 'A'
                AND     [category] = 'N'
                UNION ALL
                SELECT  [category],
                        [agentID],
                        [year],
                        [month1],
                        [month2],
                        [month3],
                        [month4],
                        [month5],
                        [month6],
                        [month7],
                        [month8],
                        [month9],
                        [month10],
                        [month11],
                        [month12]
                FROM    [dbo].[agentactivity] a
                WHERE   [type] = 'A'
                AND     [category] = 'G'
                ) a
        ) a INNER JOIN
        (
        SELECT  [category],
                [agentID],
                [year],
                [month1],
                [month2],
                [month3],
                [month4],
                [month5],
                [month6],
                [month7],
                [month8],
                [month9],
                [month10],
                [month11],
                [month12]
        FROM    (
                SELECT  'N' AS [category],
                        p.[agentID],
                        p.[periodYear] AS [year],
                        COALESCE(p.[1],0)  AS [month1],
                        COALESCE(p.[2],0)  AS [month2],
                        COALESCE(p.[3],0)  AS [month3],
                        COALESCE(p.[4],0)  AS [month4],
                        COALESCE(p.[5],0)  AS [month5],
                        COALESCE(p.[6],0)  AS [month6],
                        COALESCE(p.[7],0)  AS [month7],
                        COALESCE(p.[8],0)  AS [month8],
                        COALESCE(p.[9],0)  AS [month9],
                        COALESCE(p.[10],0) AS [month10],
                        COALESCE(p.[11],0) AS [month11],
                        COALESCE(p.[12],0) AS [month12]
                FROM    (
                        SELECT  b.[agentID],
                                b.[periodYear],
                                b.[periodMonth],
                                SUM(bf.[netDelta]) AS [netPremium]
                        FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
                                [dbo].[batch] b
                        ON      bf.[batchID] = b.[batchID]
                        GROUP BY b.[agentID], b.[periodYear], b.[periodMonth]
                        ) src
                        PIVOT 
                        (
                        SUM([netPremium])
                        FOR [periodMonth] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
                        ) p
                WHERE   [periodYear] IN (2016,2017,2018)
                UNION ALL
                SELECT  'G' AS [category],
                        p.[agentID],
                        p.[periodYear] AS [year],
                        COALESCE(p.[1],0)  AS [month1],
                        COALESCE(p.[2],0)  AS [month2],
                        COALESCE(p.[3],0)  AS [month3],
                        COALESCE(p.[4],0)  AS [month4],
                        COALESCE(p.[5],0)  AS [month5],
                        COALESCE(p.[6],0)  AS [month6],
                        COALESCE(p.[7],0)  AS [month7],
                        COALESCE(p.[8],0)  AS [month8],
                        COALESCE(p.[9],0)  AS [month9],
                        COALESCE(p.[10],0) AS [month10],
                        COALESCE(p.[11],0) AS [month11],
                        COALESCE(p.[12],0) AS [month12]
                FROM    (
                        SELECT  b.[agentID],
                                b.[periodYear],
                                b.[periodMonth],
                                SUM(bf.[grossDelta]) AS [netPremium]
                        FROM    [dbo].[batchform] bf RIGHT OUTER JOIN
                                [dbo].[batch] b
                        ON      bf.[batchID] = b.[batchID]
                        GROUP BY b.[agentID], b.[periodYear], b.[periodMonth]
                        ) src
                        PIVOT 
                        (
                        SUM([netPremium])
                        FOR [periodMonth] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
                        ) p
                WHERE   [periodYear] IN (2016,2017,2018)
                ) b
        ) b
ON      a.[agentID] = b.[agentID]
AND     a.[year] = b.[year]
AND     a.[category] = b.[category]
GROUP BY a.[category], a.[agentID], a.[year]

IF (@update = 1)
BEGIN
  DECLARE cur CURSOR LOCAL FOR
  SELECT  [agentID],
          [year],
          SUM([diff1])  AS [diff1],
          SUM([diff2])  AS [diff2],
          SUM([diff3])  AS [diff3],
          SUM([diff4])  AS [diff4],
          SUM([diff5])  AS [diff5],
          SUM([diff6])  AS [diff6],
          SUM([diff7])  AS [diff7],
          SUM([diff8])  AS [diff8],
          SUM([diff9])  AS [diff9],
          SUM([diff10]) AS [diff10],
          SUM([diff11]) AS [diff11],
          SUM([diff12]) AS [diff12]
  FROM    #compareTable
  GROUP BY [agentID],[year]
  OPEN cur
  FETCH NEXT FROM cur INTO @agentID,@year,@month1,@month2,@month3,@month4,@month5,@month6,@month7,@month8,@month9,@month10,@month11,@month12
  WHILE @@FETCH_STATUS = 0 
  BEGIN
    IF (@month1)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 1
    IF (@month2)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 2
    IF (@month3)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 3
    IF (@month4)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 4
    IF (@month5)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 5
    IF (@month6)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 6
    IF (@month7)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 7
    IF (@month8)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 8
    IF (@month9)  != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 9
    IF (@month10) != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 10
    IF (@month11) != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 11
    IF (@month12) != 0 EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = 12
    FETCH NEXT FROM cur INTO @agentID,@year,@month1,@month2,@month3,@month4,@month5,@month6,@month7,@month8,@month9,@month10,@month11,@month12
  END
  CLOSE cur
  DEALLOCATE cur
END
ELSE
BEGIN
  SELECT  [year],
          SUM([diff1])  AS [diff1],
          SUM([diff2])  AS [diff2],
          SUM([diff3])  AS [diff3],
          SUM([diff4])  AS [diff4],
          SUM([diff5])  AS [diff5],
          SUM([diff6])  AS [diff6],
          SUM([diff7])  AS [diff7],
          SUM([diff8])  AS [diff8],
          SUM([diff9])  AS [diff9],
          SUM([diff10]) AS [diff10],
          SUM([diff11]) AS [diff11],
          SUM([diff12]) AS [diff12]
  FROM    #compareTable
  WHERE   [type] = 'N'
  GROUP BY [year]
END

DROP TABLE #compareTable