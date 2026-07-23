USE [dev_alliant]
USE [alliant_test]
USE [alliant]

DECLARE @formName VARCHAR(50) = '',
        @stateID VARCHAR(2) = ''

SELECT  pf.[State],
        pf.[FormName],
        CASE WHEN pf.[Active] = 0 THEN 'No' ELSE 'Yes' END AS [Active],
        ISNULL(p.[cnt],0) AS [2017+],
        ISNULL(p2.[cnt],0) AS [All Time]
FROM    [dbo].[t_policyforms] pf LEFT OUTER JOIN
        (
        SELECT  [pformid],
                COUNT(*) AS 'cnt'
        FROM    [dbo].[t_policies]
        WHERE   [pformid] IS NOT NULL
        AND     [used] > '01-01-2017'
        GROUP BY [pformid]
        ) p
ON      pf.[PFormID] = p.[pformid] LEFT OUTER JOIN
        (
        SELECT  [pformid],
                COUNT(*) AS 'cnt'
        FROM    [dbo].[t_policies]
        WHERE   [pformid] IS NOT NULL
        GROUP BY [pformid]
        ) p2
ON      pf.[PFormID] = p2.[pformid]
WHERE   pf.[FormName] LIKE '%' + @formName + '%'
AND     pf.[State] = CASE WHEN @stateID = '' THEN pf.[State] ELSE @stateID END
ORDER BY pf.[State],pf.[FormName],p.[cnt] DESC