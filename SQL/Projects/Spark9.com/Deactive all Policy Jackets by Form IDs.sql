CREATE TABLE #policyForms
(
  [formID] INTEGER,
)

SELECT  a.*
FROM    [dbo].[t_policyforms] a INNER JOIN
        #policyForms b
ON      a.[pFormID] = b.[formID]

UPDATE  [dbo].[t_policyforms]
SET     [active] = 0
WHERE   [pFormID] IN (SELECT [formID] FROM #policyForms)

SELECT  a.*
FROM    [dbo].[t_policyforms] a INNER JOIN
        #policyForms b
ON      a.[pFormID] = b.[formID]

DROP TABLE #policyForms