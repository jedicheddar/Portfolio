USE ANTIC
DECLARE @colName VARCHAR(50) = '', -- column
        @colValue VARCHAR(100) = '', -- value
        @showTable BIT = 1

IF (@colName <> '')
BEGIN
  CREATE TABLE #columnTable ([seq] INTEGER, [table] VARCHAR(30))

  INSERT INTO #columnTable
  SELECT  ROW_NUMBER() OVER(ORDER BY t.[name]),
          t.[name] AS 'table_name'
  FROM    sys.[tables] AS t INNER JOIN 
          sys.[columns] c 
  ON      t.[OBJECT_ID] = c.[OBJECT_ID] 
  WHERE   c.[name] LIKE '%' + @colName + '%'
  ORDER BY t.[name]

  IF (@colValue <> '')
  BEGIN
    CREATE TABLE #valueTable ([table] VARCHAR(30), [value] VARCHAR(100))
    DECLARE @sql NVARCHAR(1000),
            @seq INTEGER = 0,
            @table NVARCHAR(30)

    SELECT @seq = MIN([seq]) FROM #columnTable
    WHILE @seq IS NOT NULL
    BEGIN
      SELECT @table = [table] FROM #columnTable WHERE [seq] = @seq

      SET @sql = N'SELECT ''' + @table + ''', [' + @colName + '] FROM [' + @table + '] WHERE [' + @colName + '] = ''' + @colValue + ''''
      INSERT INTO #valueTable
      EXEC sp_executesql @sql

      IF (@showTable = 1)
      BEGIN
        DECLARE @count INTEGER = 0
        SELECT @count = COUNT(*) FROM #valueTable WHERE [table] = @table

        IF (@count > 0)
        BEGIN
          SET @sql = N'SELECT * FROM [' + @table + '] WHERE [' + @colName + '] = ''' + @colValue + ''''
          EXEC sp_executesql @sql
        END
      END
      
      SELECT @seq = MIN([seq]) FROM #columnTable WHERE [seq] > @seq
    END

    SELECT  DISTINCT *
    FROM    #valueTable
    ORDER BY [value]

    DROP TABLE #valueTable
  END
  ELSE
  BEGIN
    SELECT  *
    FROM    #columnTable
    ORDER BY [table]
  END
  DROP TABLE #columnTable
END
ELSE
  PRINT 'Please enter a column name'