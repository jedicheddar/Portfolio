DECLARE @year INT = YEAR(DATEADD(MONTH, -2, GETDATE())), --0=All
        @month INT = MONTH(DATEADD(MONTH, -2, GETDATE())), --0=All
        @override BIT = 0

DECLARE @startDate DATETIME = GETDATE(),
        @endDate DATETIME = GETDATE()

IF(@override = 1)
BEGIN
  SET @month = 8
  SET @year = 2019
END

SET @startDate = DATEFROMPARTS(@year, @month, 25)
SET @endDate   = DATEFROMPARTS(YEAR(DATEADD(MONTH, 1, @startDate)), MONTH(DATEADD(MONTH, 1, @startDate)), 25)

SELECT  COUNT(*) AS [Count],
        @startDate AS [Start],
        @endDate AS [End]
FROM    [job]
WHERE   [job].[suffix] = 1
AND     [stat] = 'F'
AND     [fulfilleddate] BETWEEN @startDate AND @endDate
AND     [fulfillsoftware] = 'Softpro'
