USE [dev_alliant]
USE [alliant_test]
USE [alliant]

CREATE TABLE #policyForms
(
  [formID] INTEGER,
)

INSERT INTO #policyForms ([formID]) VALUES (356)
INSERT INTO #policyForms ([formID]) VALUES (450)
INSERT INTO #policyForms ([formID]) VALUES (136)
INSERT INTO #policyForms ([formID]) VALUES (329)
INSERT INTO #policyForms ([formID]) VALUES (138)
INSERT INTO #policyForms ([formID]) VALUES (382)
INSERT INTO #policyForms ([formID]) VALUES (384)
INSERT INTO #policyForms ([formID]) VALUES (410)
INSERT INTO #policyForms ([formID]) VALUES (460)
INSERT INTO #policyForms ([formID]) VALUES (271)
INSERT INTO #policyForms ([formID]) VALUES (272)
INSERT INTO #policyForms ([formID]) VALUES (599)
INSERT INTO #policyForms ([formID]) VALUES (365)
INSERT INTO #policyForms ([formID]) VALUES (551)
INSERT INTO #policyForms ([formID]) VALUES (394)
INSERT INTO #policyForms ([formID]) VALUES (414)
INSERT INTO #policyForms ([formID]) VALUES (415)
INSERT INTO #policyForms ([formID]) VALUES (483)
INSERT INTO #policyForms ([formID]) VALUES (485)

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