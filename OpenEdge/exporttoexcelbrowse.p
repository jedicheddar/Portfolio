&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
@file exporttoexcelbrowse.p
@description Exports all of the browse widgets into an excel spreadsheet

@param BrowseList;char;The handles of the browse windows in a comma delimited list
@param FileName;char;The relative or absolute file path

@note Each browse widget is designated its own worksheet. As only the browse
      handles are passed in, the query for the report is the prepare-string
      attribute of the browse's query if available, otherwise the query will
      be "preselect each <table> no-lock". The columns on the report will be the
      columns that are displayed in the browse. The column headers will be
      the browse column labels if available, otherwise the column name.
      The sheets name will be the title of the browse if available, otherwise
      the name of the browse.

7.12.2019 DS - Added etime to filename; removed ImportFile preprocessor; reorganized CSV file output
  ----------------------------------------------------------------------*/

define input parameter pBrwList as character no-undo.
define input parameter pFileName as character no-undo.

{lib/std-def.i}
{lib/excel.i}
{lib/add-delimiter.i}

/* browse handle */
define variable iBrowse      as integer no-undo.
define variable hBrowse      as handle no-undo.
define variable hColumn      as handle no-undo.

/* query handle */
define variable cQueryString as character no-undo.
define variable hQuery       as handle no-undo.
define variable hBrowseQuery as handle no-undo.
define variable hBuffer      as handle no-undo.

define variable iTableRow    as integer no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* check for a relative filename */
if index(pFileName,"\") = 0
 then
  do:
    std-ch = "".
    publish "GetReportDir" (output std-ch).
    if std-ch = ""
     then std-ch = os-getenv("TEMP").
    if substring(std-ch, length(std-ch) - 1, 1) <> "\"
     then std-ch = std-ch + "\".
    pFileName = std-ch + pFileName.
  end.

/* Check if file exists; if so, append etime to make it highly likely unique */
file-info:filename = pFileName.
if file-info:file-type <> ?  
 then pFileName = pFileName + "_" + string(etime).

/* check if there is an extension */
if index(pFileName,".") = 0
 then pFileName = pFileName + ".xlsx".


session:set-wait-state("GENERAL").

DO ON ERROR UNDO, LEAVE
   ON STOP UNDO, LEAVE:

 {lib/pbshow.i "''"}
 {lib/pbupdate.i "'Launching Excel'" 5}
 /* create the excel connection */
 create "excel.application" chExcel.

 /* set the number of sheet in the workbook */
 chExcel:SheetsInNewWorkbook = num-entries(pBrwList).

 /* add the workbook */
 chWorkbook = chExcel:Workbooks:Add().

 do iBrowse = 1 to num-entries(pBrwList):
  {lib/pbupdate.i "'Creating Worksheet'" 10}

  chWorkbook:Worksheets(iBrowse):Activate.
  assign
    /* reset the row counter */
    iRow = 1
    /* the browse handle */
    hBrowse = handle(entry(iBrowse,pBrwList))
    /* create the worksheet */
    chWorksheet = chWorkbook:Worksheets(iBrowse)
    /* get the browse query and buffer */
    hBrowseQuery = hBrowse:query
    hBuffer = hBrowseQuery:get-buffer-handle(1)
    cQueryString = (if hBrowseQuery:prepare-string <> ? then hBrowseQuery:prepare-string else "preselect each " + hBuffer:table + " no-lock")
    .
  
  /* the first row should be the header */
  {lib/pbupdate.i "'Adding the header'" 25}
  cLine = "".
  iTotalCol = 0.
  do std-in = 1 to hBrowse:num-columns:
    hColumn = hBrowse:get-browse-column(std-in).
    case hColumn:data-type:
     when "logical"   or
     when "character" then
      if hColumn:name = "agentID"
       then dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + "000000".
       else dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatText}.
     when "integer"   then
      if index(hColumn:name, "ID") > 0
       then dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatText}.
       else dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatNumber}.
     when "decimal"   then
      do:
        if hColumn:label matches "*%*" or hColumn:label matches "*Percent*"
         then dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatPercentage}.
         else dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatAccounting}.
      end.
     when "date"     or
     when "datetime" then dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatDate}.
     otherwise dataTypes = addDelimiter(dataTypes, {&msg-dlm}) + {&xlFormatText}.
    end case.
    iTotalCol = iTotalCol + 1.
    cValue = hColumn:name.
    if hColumn:label = cValue
     then cLine = addDelimiter(cLine, {&msg-dlm}) + cValue.
     else cLine = addDelimiter(cLine, {&msg-dlm}) + "~"" + replace(hColumn:label, "!", " ") + "~"".
  end.
  
  {lib/pbupdate.i "'Exporting the data'" 50}

  /* build a CSV file */
  output to value(pFileName).
  put unformatted cLine skip.

  create query hQuery.
  hQuery:set-buffers(hBuffer).
  hQuery:query-prepare(cQueryString).
  hQuery:query-open().
  hQuery:get-first().

  iTableRow = 1.
  repeat while not hQuery:query-off-end:
    cLine = "".
    do std-in = 1 to hBrowse:num-columns:
      hColumn = hBrowse:get-browse-column(std-in).
      std-ha = hBuffer:buffer-field(hColumn:name).
      case std-ha:data-type:
       when "character" then cLine = addDelimiter(cLine, {&msg-dlm}) + "=~"" + std-ha:buffer-value() + "~"".
       when "decimal" then
        if hColumn:label matches "*%*" or hColumn:label matches "*Percent*"
         then cLine = addDelimiter(cLine, {&msg-dlm}) + (if std-ha:buffer-value() = ? then "" else string(std-ha:buffer-value() / 100)).
         else cLine = addDelimiter(cLine, {&msg-dlm}) + (if std-ha:buffer-value() = ? then "" else std-ha:buffer-value()).
       otherwise cLine = addDelimiter(cLine, {&msg-dlm}) + (if std-ha:buffer-value() = ? then "" else std-ha:buffer-value()).
      end case.
    end.
    if cLine > ""
     then
      do:
        put unformatted cLine skip.
        iTableRow = iTableRow + 1.
      end.
    hQuery:get-next().
  end.
  output close.

  hQuery:query-close().
  delete object hQuery.

  /* import the sheet into Excel */
  assign
    file-info:file-name                       = pFileName
    std-lo                                    = chWorkSheet:QueryTables:Add("TEXT;" + file-info:full-pathname, chWorkSheet:cells(1,1))
    chQueryTable                              = chWorkSheet:QueryTables(1)
    chQueryTable:FieldNames                   = false
    chQueryTable:RowNumbers                   = false
    chQueryTable:FillAdjacentFormulas         = false
    chQueryTable:PreserveFormatting           = true
    chQueryTable:RefreshOnFileOpen            = false
    chQueryTable:RefreshStyle                 = 1
    chQueryTable:SavePassword                 = false
    chQueryTable:SaveData                     = true
    chQueryTable:AdjustColumnWidth            = true
    chQueryTable:RefreshPeriod                = 0
    chQueryTable:TextFilePromptOnRefresh      = false
    chQueryTable:TextFilePlatform             = 437
    chQueryTable:TextFileStartRow             = 1
    chQueryTable:TextFileParseType            = 1
    chQueryTable:TextFileTextQualifier        = 1
    chQueryTable:TextFileConsecutiveDelimiter = false
    chQueryTable:TextFileTabDelimiter         = false
    chQueryTable:TextFileSemicolonDelimiter   = false
    chQueryTable:TextFileCommaDelimiter       = false
    chQueryTable:TextFileSpaceDelimiter       = false
    chQueryTable:TextFileOtherDelimiter       = {&msg-dlm}
    chQueryTable:TextFileTrailingMinusNumbers = true
    chQueryTable:BackgroundQuery              = false
    std-lo                                    = chQueryTable:Refresh
    .
    
  {lib/pbupdate.i "'Configuring Columns'" 75}
  /* set the colors */
  do std-in = 1 to iTableRow:
    cCell = "A" + string(std-in) + ":" + entry(iTotalCol, {&xlColumn}) + string(std-in).
    if std-in = 1
     then 
      assign
        chWorksheet:Range(cCell):Interior:ColorIndex = {&xlHeaderBackColor}
        chWorksheet:Range(cCell):FONT:ColorIndex     = {&xlHeaderFontColor}
        chWorksheet:Range(cCell):HorizontalAlignment = {&xlHAlignCenter}
        .
     else chWorksheet:Range(cCell):Interior:ColorIndex = if std-in modulo 2 = 0 then {&xlEvenRow} else {&xlOddRow}.
  end.
  
  /* set the column formatting */
  do std-in = 1 to iTotalCol:
    cCell = entry(std-in, {&xlColumn}) + "2:" + entry(std-in, {&xlColumn}) + string(iTableRow).
    chWorksheet:Range(cCell):NumberFormat = entry(std-in, dataTypes, {&msg-dlm}).
  end.
  
  /* rename the worksheet */
  release object chWorksheet.
end.

{lib/pbupdate.i "'Releasing Excel'" 100}
{lib/pbhide.i}

/* show the document */
chExcel:visible = true.
chExcel:WindowState = {&xlWindowMaximized}.
chExcel:ActiveWindow:Activate().

/* release the objects */
release object chExcel.
END.

session:set-wait-state("").

publish "AddTempFile" (pFileName, pFileName).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


