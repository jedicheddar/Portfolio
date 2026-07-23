GO

DECLARE @state varchar(2) = '' -- Enter the state

IF (@state <> '')
BEGIN
  SELECT  [PFormID],
          [FormName],
          [Version],
          [Active],
          [SignatureOffset],
          [FormId],
          [ActiveId]
  FROM    [dbo].[t_policyforms]
  WHERE   [State] = @state
  AND     [Active] = 1
  ORDER BY [FormName] asc
  
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'Addendum to ALTA Short Form Residential Limited Coverage Junior Loan Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] = 'ALTA Short Form Residential Limited Coverage Junior Loan Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Commitment (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE '%ALTA Commitment%'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Expanded Coverage Residential Loan Policy - Assessments Priority (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] = 'ALTA Expanded Coverage Residential Loan Policy - Assessments Priority'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Expanded Coverage Residential Loan Policy - Current Assessments (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] = 'ALTA Expanded Coverage Residential Loan Policy - Current Assessments'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Homeowner''''s Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Homeowners Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Loan Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Loan Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Owner''''s Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Owners Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Residential Limited Coverage Junior Loan Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Residential Limited Coverage Junior Loan Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Residential Limited Coverage Mortgage Modification Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Residential Limited Coverage Mortgage Modification Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Short Form Expanded Coverage Residential Loan Policy - Assessments Priority (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Short Form Expanded Coverage Residential Loan Policy - Assessments Priority'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  TOP 1
          [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Short Form Expanded Coverage Residential Loan Policy - Current Assessments (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Short Form Expanded Coverage Residential Loan Policy - Current Assessments'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          'LSFAP',
          1
  FROM    (
          SELECT  'ALTA Short Form Residential Loan Policy - Assessments Priority (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          'LSFCV',
          1
  FROM    (
          SELECT  'ALTA Short Form Residential Loan Policy - Current Assessments (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
  UNION ALL
  SELECT  [Form],
          [FormId],
          [Count]
  FROM    (
          SELECT  'ALTA Short Form Residential Limited Coverage Junior Loan Policy (2021)' AS [Form],
                  [FormId],
                  COUNT(*) AS [Count],
                  RANK() OVER (ORDER BY COUNT(*) DESC) AS [Rank]
          FROM    [dbo].[t_policyforms]
          WHERE   [FormName] LIKE 'ALTA Short Form Residential Limited Coverage Junior Loan Policy'
          GROUP BY [FormId]
          ) A
  WHERE   [Rank] = 1
END
ELSE
BEGIN
  PRINT 'Please enter a state'
END