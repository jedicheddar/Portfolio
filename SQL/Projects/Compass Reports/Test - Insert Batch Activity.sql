DECLARE @year INTEGER = 0,
        @month INTEGER = 0,
        @agentID VARCHAR(30) = 'ALL',
        @onlyInsert BIT = 0

IF (@onlyInsert = 0)
  EXEC [dbo].[spAgentActivityBatch] @agentID = @agentID, @year = @year, @month = @month
ELSE
BEGIN
  DECLARE @month1 DECIMAL(18,2) = 0,
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
          @month12 DECIMAL(18,2) = 0,
          @activityID INTEGER = 0

  SELECT @month1  = @month FROM [period] WHERE @month = 1
  SELECT @month2  = @month FROM [period] WHERE @month = 2
  SELECT @month3  = @month FROM [period] WHERE @month = 3
  SELECT @month4  = @month FROM [period] WHERE @month = 4
  SELECT @month5  = @month FROM [period] WHERE @month = 5
  SELECT @month6  = @month FROM [period] WHERE @month = 6
  SELECT @month7  = @month FROM [period] WHERE @month = 7
  SELECT @month8  = @month FROM [period] WHERE @month = 8
  SELECT @month9  = @month FROM [period] WHERE @month = 9
  SELECT @month10 = @month FROM [period] WHERE @month = 10
  SELECT @month11 = @month FROM [period] WHERE @month = 11
  SELECT @month12 = @month FROM [period] WHERE @month = 12

  EXEC [dbo].[spInsertAgentActivity] 	@agentID = @agentID, @year = @year,  @category = 'P', @stat = 'O', @type = 'R', @month12 = @month12,  @activityID = @activityID OUTPUT
END