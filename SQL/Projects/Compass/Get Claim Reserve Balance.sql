USE [COMPASS]

SELECT  c.[claimID],
        c.[approved reserve] - a.[posted payments] AS [reserve]
FROM    (
        SELECT  [claimID],
                SUM(c.[transAmount]) AS [approved reserve]
        FROM    [claimadjtrx] c
        GROUP BY [claimID]
        ) c INNER JOIN
        (
        SELECT  CONVERT(INTEGER,a.[refID]) AS [claimID],
                SUM(a.[transAmount]) AS [posted payments]
        FROM    [aptrx] a
        GROUP BY [refID]
        ) a
ON      c.[claimID] = a.[claimID]