DECLARE @stateID VARCHAR(30) = '',
        @deleteCounty BIT = 0,
        @deleteStatCode BIT = 0,
        @deleteStateForm BIT = 0

IF (@stateID <> '')
BEGIN
  -- Count the rows
  SELECT 'County', COUNT(*) AS [count] FROM [county] WHERE [stateID] = @stateID
  UNION
  SELECT 'StatCode', COUNT(*) AS [count] FROM [statcode] WHERE [stateID] = @stateID
  UNION
  SELECT 'StateForm', COUNT(*) AS [count] FROM [stateform] WHERE [stateID] = @stateID

  -- Validate that there are no missing form ids
  SELECT  *
  FROM    [statcode]
  WHERE   [formID] NOT IN (
          SELECT  [formID]
          FROM    [stateform]
          WHERE   [stateID] = @stateID
          )
  AND     [stateID] = @stateID


  IF (@deleteCounty = 1)
    DELETE FROM [county] WHERE [stateID] = @stateID

  IF (@deleteStatCode = 1)
    DELETE FROM [statcode] WHERE [stateID] = @stateID

  IF (@deleteStateForm = 1)
    DELETE FROM [stateform] WHERE [stateID] = @stateID

  -- Count the rows if needed
  IF (@deleteCounty = 1 OR @deleteStatCode = 1 OR @deleteStateForm = 1)
    SELECT 'County', COUNT(*) AS [count] FROM [county] WHERE [stateID] = @stateID
    UNION
    SELECT 'StatCode', COUNT(*) AS [count] FROM [statcode] WHERE [stateID] = @stateID
    UNION
    SELECT 'StateForm', COUNT(*) AS [count] FROM [stateform] WHERE [stateID] = @stateID
END