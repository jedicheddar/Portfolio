GO

DECLARE @state VARCHAR(2) = '', -- The state abbreviation
        @valid INT = 0

--start build the CPL type
DECLARE @addLender BIT = 0, -- use 1 if need lender CPL
        @addBuyer BIT = 0,  -- use 1 if need buyer CPL
        @addSeller BIT = 0,  -- use 1 if need seller CPL
        @CPLType VARCHAR(100) = '',
        @MaxRownum INT,
        @Iter INT,
        @item VARCHAR(20)
DECLARE @CPLTypeTable TABLE (ord INT,CPLType VARCHAR(20))
IF (@addLender = 1) BEGIN INSERT INTO @CPLTypeTable (ord,CPLType) VALUES (1,'Lender') END
IF (@addBuyer = 1) BEGIN INSERT INTO @CPLTypeTable (ord,CPLType) VALUES (2,'Buyer') END
IF (@addSeller = 1) BEGIN INSERT INTO @CPLTypeTable (ord,CPLType) VALUES (3,'Seller') END

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY ord)
    ,*
INTO #temp
FROM @CPLTypeTable
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN
  SELECT @item=[CPLType] FROM #temp WHERE RowNum = @Iter
  IF (@CPLType <> '')
  BEGIN
    SET @CPLType = @CPLType + ','
  END
  SET @CPLType = @CPLType + @item
  SET @Iter = @Iter + 1
END
DROP TABLE #temp
--end build CPL type

SELECT @valid=count(*) FROM [dbo].[t_states] WHERE [state_abbr]=@state AND [IsGroup]=1

IF (@valid > 0 AND @CPLType <> '')
BEGIN
  EXEC [dbo].[spValidateCPL]
  -- The state abbreviation
      @state = @state
  -- The type of form (will validate that the type is present)
     ,@type = @CPLType
  EXEC [dbo].[spActivateCPL]
  -- The state abbreviation
      @state = @state
  -- The type of form (will validate that the type is present)
     ,@type = @CPLType
  EXEC [dbo].[spValidateCPL]
  -- The state abbreviation
      @state = @state
  -- The type of form (will validate that the type is present)
     ,@type = @CPLType
END
GO