GO
SET NOCOUNT ON;

DECLARE @state VARCHAR(2) = '', -- The state abbreviation
        @AltaFooter BIT = 1, -- ALTA Footer (1 = use)
        @agentSpec BIT = 0, --  (1 = use) Adds the text "Name of Issuing Agent or Approved Attorney (hereafter,Issuing Agent or Approved Attorney, as the case may require" before agent name for Lender CPL 
        @footerLabel VARCHAR(200) = '', -- The footer label (ANTIC #1077)
        @footerCopy VARCHAR(200) = '', -- The footer copyright (2006-2014)
        @footerDesc VARCHAR(200) = '', -- The footer description (ALTA Closing Protection Letter (04-02-2014) - Single Transaction)
        @fontSize INT = 9, -- The font size 
        @formID VARCHAR(20) = '', -- The formID (leave blank unless new state)
        @activate BIT = 0

--start build the CPL type
DECLARE @addLender BIT = 0, -- use 1 if need lender CPL
        @addBuyer BIT = 0,  -- use 1 if need buyer CPL
        @addSeller BIT = 0,  -- use 1 if need seller CPL
        @CPLType VARCHAR(100) = '',
        @MaxRownum INT,
        @Iter INT,
        @item VARCHAR(20),
        @return INT = 0
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

IF (@CPLType = '')
BEGIN
  SELECT 'No CPL Type provided.'
  RETURN
END

IF (@CPLType <> '' AND @footerLabel <> 'ANTIC #')
BEGIN
  PRINT '-----Adding and Activating CPLs in database ' + DB_NAME() + ' for the type(s) ' + @CPLType + '-----'
  IF (@return = 0)
  BEGIN
    EXEC @return = [dbo].[spCreateCPL]
    -- The state abbreviation
        @state = @state
    -- The type of form (should be Lender, Buyer, or Seller)
       ,@type = @CPLType
    -- The agent specifier (default 0 [to not use])
       ,@agentSpec = @agentSpec
    -- If the CPL uses the ALTA footer or not (default 1 [to use])
       ,@ALTAFooter = @AltaFooter
    -- The footer label (will validate is there)
       ,@footerLabel = @footerLabel
    -- The footer copyright (will validate is there - i.e. 2006-2014)
       ,@footerCopy = @footerCopy
    -- The footer description (if applicable - i.e. ALTA Closing Protection Letter (04-02-2014) - Single Transaction)
       ,@footerDesc = @footerDesc
    -- The font size (default 8)
       ,@fontSize = @fontSize
    -- The formID (will validate that there is not a form ID for a new form)
       ,@formID = @formID
  END
  
  IF (@return > 0)
  BEGIN
    SELECT 'There was an error inserting the CPL into the environment.'
    RETURN
  END

  IF (@activate = 1)
  BEGIN
    EXEC @return = [dbo].[spActivateCPL]
    -- The state abbreviation
        @state = @state
    -- The type of form (will validate that the type is present)
        ,@type = @CPLType
  END

  PRINT '-----Validating the CPLs in ' + DB_NAME() + ' for the type(s) ' + @CPLType + '-----'
  EXEC [dbo].[spValidateCPL]
  -- The state abbreviation
      @state = @state
  -- The type of form (will validate that the type is present)
      ,@type = @CPLType
END
ELSE
BEGIN
  PRINT 'Invalid state, CPL Type, or Footer'
END
GO

