&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
@file rbuild-dynamic-browse.i
@description Procedures to build a browse based on user-defined columns
@Modified
Date		Name	Description
----		----	-----------
03.30.23    SB      Task#103627- Exclude agent serialize-hidden fields from the selected list
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* temp tables */
{tt/listfield.i}

/* functions and procedures */
{lib/find-widget.i}
{lib/build-browse.i &noTitle=true}

/* variables */
{lib/std-def.i}
define variable dDynanicBrowseColumnWidth as decimal no-undo.
define variable hDynamicBrowseFrame       as handle  no-undo.

&if defined(integerOnly) = 0 &then
&scoped-define integerOnly false
&endif

&if defined(excludeColumn) = 0 &then
&scoped-define excludeColumn ""
&endif

&if defined(resizeColumn) = 0 &then
&scoped-define resizeColumn ""
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getBrowseHandle Include 
FUNCTION getBrowseHandle RETURNS WIDGET-HANDLE
  (  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getBrowseWidth Procedure
FUNCTION getBrowseWidth RETURNS DECIMAL
  (  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getKeyfield Procedure
FUNCTION getKeyfield RETURNS CHARACTER
  (  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isBrowseTooBig Procedure
FUNCTION isBrowseTooBig RETURNS LOGICAL
  (  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Include
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: INCLUDE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Include 


/* ***************************  Main Block  *************************** */

empty temp-table listfield.
dDynanicBrowseColumnWidth = 0.

&if defined(frame-browse) = 0 &then
if valid-handle(frame fBrowse:handle) 
 then hDynamicBrowseFrame = frame fBrowse:handle.
&else
hDynamicBrowseFrame = {&frame-browse}.
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BuildDynamicBrowse Include 
PROCEDURE BuildDynamicBrowse :
/*------------------------------------------------------------------------------
@description Build the dynamic browse
------------------------------------------------------------------------------*/
  /* parameters */
  define input parameter pQuery as character no-undo.

  /* variables */
  define variable hQuery       as handle no-undo.
  define variable hBuffer      as handle no-undo.
  define variable hTable       as handle no-undo.
  define variable hTableBuffer as handle no-undo.

  /* create buffer and table */
  create buffer hBuffer for table "{&table}".
  create temp-table hTable.
  
  /* the keyfield is the field used to pass into each publish call */
  hTable:add-new-field("keyfield","character",0,"x(50)").
  
  /* put the browse columns into the table */
  if not can-find(first listfield)
   then run BuildDynamicBrowseColumns.
  for each listfield no-lock:
    hTable:add-new-field(listfield.columnBuffer,listfield.dataType,0,listfield.columnFormat).
  end.
  hTable:temp-table-prepare("{&table}").
  hTableBuffer = hTable:default-buffer-handle.

  /* add the keyfield value to the field */
  create query hQuery.
  hQuery:set-buffers(hBuffer).
  hQuery:query-prepare(pQuery).
  hQuery:query-open().
  hQuery:get-first().
  repeat while not hQuery:query-off-end:
    hTableBuffer:buffer-create().
    hTableBuffer:buffer-copy(hBuffer).
    hTableBuffer:buffer-field("keyfield"):buffer-value() = hBuffer:buffer-field({&keyfield}):buffer-value().
    hQuery:get-next().
  end.
  hQuery:query-close().
  
  /* build the browse */
  run BuildBrowse (hTable, temp-table listfield:handle, hDynamicBrowseFrame, {&entity}).
   
  /* resize the colums if the preprocessor is defined */
  &if defined(resizeColumn) <> 0 &then
  run ResizeDynamicBrowseColumns ({&resizeColumn}).
  &endif
  
  /* cleanup handles */
  delete object hQuery.
  delete object hBuffer.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BuildDynamicBrowseColumns Include 
PROCEDURE BuildDynamicBrowseColumns :
/*------------------------------------------------------------------------------
@description Build the temp table that will be used in the dynamic browse
------------------------------------------------------------------------------*/
  /* variables */
  define variable hBuffer   as handle    no-undo.
  define variable hField    as handle    no-undo.
  define variable cLabel    as character no-undo case-sensitive.
  define variable cUserList as character no-undo.
  
  /* get the reference colums from the config */
  publish "GetDynamicBrowseColumns" (substring(source-procedure:name, index(source-procedure:name, "/") + 1), output cUserList).
  
  /* create buffer */
  create buffer hBuffer for table "{&table}".
  
  /* build the browse column list */
  empty temp-table listfield.
  do std-in = 1 to num-entries(cUserList):
    hField = hBuffer:buffer-field(entry(std-in, cUserList)).
    if valid-handle(hField)
     then
      do:
        /* get the label */
        cLabel = hField:column-label.
        if cLabel = hField:name
         then cLabel = hField:label.
        
        if hField:serialize-hidden then
          next.

        /* create a row in the browse column list */
        create listfield.
        assign
          listfield.columnBuffer = hField:name
          listfield.displayName = cLabel
          listfield.dataType = hField:data-type
          listfield.columnFormat = hField:format
          .
        /* set the column widths */
        case hField:data-type:
         when "datetime"  then listfield.columnWidth = 15.
         when "decimal"   then listfield.columnWidth = 15.
         when "integer"   then listfield.columnWidth = 10.
         when "logical"   then listfield.columnWidth = 10.
         when "character" then listfield.columnWidth = 25.
         otherwise listfield.columnWidth = 25.
        end case.
      end.
  end.
  
  /* cleanup handles */
  delete object hBuffer no-error.
  delete object hField no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BuildDynamicBrowseTotalRow Include 
PROCEDURE BuildDynamicBrowseTotalRow :
/*------------------------------------------------------------------------------
@note Build the total row for a dynamic browse
------------------------------------------------------------------------------*/
  /* parameters */
  define input parameter pQuery as character no-undo.
  
  /* variables used to loop */
  define variable i        as integer   no-undo.
  define variable j        as integer   no-undo.
  
  /* variables used to tell if the width of the columns are greater than the frame */
  define variable lValid   as logical   no-undo initial true.
  
  /* variables used to hold the array of devimal values */  
  define variable dTotal   as decimal   no-undo extent.
  
  /* variables used to hold the attributes of the widget */
  define variable iCol     as decimal   no-undo.
  define variable iRow     as decimal   no-undo.
  define variable iWidth   as decimal   no-undo.
  define variable iPos     as integer   no-undo.
  define variable dataType as character no-undo.
  define variable scrValue as character no-undo.
  define variable svFormat as character no-undo.
  define variable hToolTip as character no-undo.

  /* used to hold the handles */
  define variable hBrowse  as handle    no-undo.
  define variable hField   as handle    no-undo.
  define variable hQuery   as handle    no-undo.
  define variable hBuffer  as handle    no-undo.
  
  /* drop and recreate a "pool" to hold the widgets */
  delete widget-pool "referenceTotal" no-error.
  create widget-pool "referenceTotal" persistent.
  
  /* get the browse */
  hBrowse = getBrowseHandle().
  if not valid-handle(hBrowse) or hBrowse:type <> "BROWSE"
   then return.
   
  /* resize the colums if the preprocessor is defined */
  &if defined(resizeColumn) <> 0 &then  
  run ResizeDynamicBrowseColumns ({&resizeColumn}).
  &endif
  
  /* set the array extent to the number of columns */
  if extent(dTotal) = ?
   then extent(dTotal) = hBrowse:num-columns.

  /* set the browse height for the total row */
  hBrowse:height-pixels = hBrowse:height-pixels - 23.
  
  /* clear our the array and remove existing total row */
  do i = 1 to extent(dTotal):
    dTotal[i] = 0.
  end.

  /* get the totals for each column */
  create buffer hBuffer for table "{&table}".
  create query hQuery.
  hQuery:add-buffer(hBuffer).
  hQuery:query-prepare(pQuery).
  hQuery:query-open().
  hQuery:get-first().
  repeat while not hQuery:query-off-end:
    do i = 1 to hBrowse:num-columns:
      hField = hBuffer:buffer-field(hBrowse:get-browse-column(i):name).
      if valid-handle(hField)
       then
        if lookup(hField:name,{&excludeColumn}) = 0 and not isBrowseTooBig()
         then
          do:
            if hField:data-type = "DECIMAL" or hField:data-type = "INTEGER"
             then dTotal[i] = dTotal[i] + hField:buffer-value().
             else dTotal[i] = lf-min.
          end.
         else dTotal[i] = lf-min.
    end.
    hQuery:get-next().
  end.
  
  /* create the widget */
  do i = 1 to extent(dTotal):
    /* if the browse is too big for the frame, then only make the "Total" widget */
    if isBrowseTooBig() and i > 1
     then next.
     
    assign
      hField   = hBrowse:get-browse-column(i)
      iCol     = hField:column + hBrowse:col
      iWidth   = hField:width-chars - 0.1
      hToolTip = ""
      .
    
    /* first row */
    if i = 1
     then
      assign
        scrValue = "Totals"
        dataType = "CHARACTER"
        svFormat = "x(8)"
        .
     else
      /* check if valid row */
      if dTotal[i] = lf-min or dTotal[i] = 0
       then
        assign
          scrValue = ""
          dataType = "CHARACTER"
          svFormat = "x(8)"
          .
       else
        do:
          scrValue = string(dTotal[i]).
          dataType = "DECIMAL".
          svFormat = "".
          
          /* account for negative numbers */
          if dTotal[i] < 0
           then svFormat = svFormat + "(".
          
          /* loop through the absolute value of the number cast as an int64 */
          do j = length(string(int64(absolute(dTotal[i])))) to 1 by -1:
            if j modulo 3 = 0
             then svFormat = svFormat + (if j = length(string(int64(absolute(dTotal[i])))) then ">" else ",>").
             else svFormat = svFormat + (if j = 1 then "Z" else ">").
          end.
       
          /* if the number had a decimal value */
          if index(scrValue, ".") > 0 and not {&integerOnly}
           then svFormat = svFormat + ".99".
           
          /* account for negative numbers */
          if dTotal[i] < 0
           then svFormat = svFormat + ")".
          
          iPos = hField:width-pixels - font-table:get-text-width-pixels(svFormat, 1).
          iPos = iPos / font-table:get-text-width-pixels(" ", 1).
          
          if iPos < 2
           then
            assign
              hToolTip = string(scrValue,replace(svFormat,"Z","9"))
              scrValue = "*"
              dataType = "CHARACTER"
              svFormat = "x(8)"
              .
           else svFormat = fill(" ", iPos) + svFormat.
        end.
        
    /* build the widget */
    hField = ?.
    create text hField in widget-pool "referenceTotal" assign
      frame         = hDynamicBrowseFrame
      row           = hBrowse:row + hBrowse:height-chars + 0.1
      column        = iCol
      data-type     = dataType
      format        = svFormat
      screen-value  = scrValue
      visible       = true
      width         = iWidth
      font          = 1
      name          = "totalRow" + string(i)
      .
    
    if hToolTip <> ""
     then hField:tooltip = hToolTip.
  end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ResizeDynamicBrowseColumns Include 
PROCEDURE ResizeDynamicBrowseColumns :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input parameter pColumn as character no-undo.
  
  /* variables used to tell how many pixels to add to the columns */
  define variable dAddWidth as decimal no-undo.
  
  /* variables used to tell how many columns are shown  */
  define variable dColAvail as integer no-undo.
  
  /* variables used to hold the handles */
  define variable hBrowse   as handle no-undo.
  define variable hColumn   as handle no-undo.
  
  /* exit if the original column width isn't set */
  if dDynanicBrowseColumnWidth = 0
   then return.
  
  /* resize the column only if there is room to spare */
  hBrowse = getBrowseHandle().
  if valid-handle(hBrowse) and not isBrowseTooBig()
   then 
    do:
      /* get only columns available */
      do std-in = 1 to hBrowse:num-columns:
        hColumn = hBrowse:get-browse-column(std-in).
        if valid-handle(hColumn) and lookup(hColumn:name, pColumn) > 0
         then dColAvail = dColAvail + 1.
      end.
      dAddWidth = (hDynamicBrowseFrame:width-pixels - getBrowseWidth()) / dColAvail.
    end.
   else dAddWidth = 0.
  
  /* set the column sizes */
  if valid-handle(hBrowse) and hBrowse:type = "BROWSE"
   then
    do:
      hColumn = hBrowse:first-column.
      /* loop through all columns */
      do while valid-handle(hColumn):
        /* first set all the columns to their original value */
        for first listfield no-lock
            where listfield.columnBuffer = hColumn:name:
            
          hColumn:width = listfield.columnWidth.
        end.
        /* resize the columns specified */
        do std-in = 1 to num-entries(pColumn):
          if hColumn:name = entry(std-in, pColumn)
           then hColumn:width-pixels  = dDynanicBrowseColumnWidth + dAddWidth.
        end.
        hColumn = hColumn:next-column.
      end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetDynamicBrowseColumns Include 
PROCEDURE SetDynamicBrowseColumns :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* variables */
  define variable hBuffer        as handle    no-undo.
  define variable hField         as handle    no-undo.
  define variable cLabel         as character no-undo case-sensitive.
  define variable pAvailableList as character no-undo.
  define variable pSelectedList  as character no-undo.
  
  /* build the current column list if not done so already */
  if not can-find(first listfield)
   then run BuildDynamicBrowseColumns.
  
  /* get the selected column list */
  for each listfield no-lock:
    pSelectedList = addDelimiter(pSelectedList, ",") + replace(listfield.displayName, "!", " ") + "," + listfield.columnBuffer.
  end.
  
  /* get the columns are not in the listfield */
  create buffer hBuffer for table "{&table}".
  do std-in = 1 to hBuffer:num-fields:
    hField = hBuffer:buffer-field(std-in).
    if valid-handle(hField)
     then
      do:
        /* get the label */
        cLabel = hField:column-label.
        if cLabel = hField:name
         then cLabel = hField:label.
                 
        if hField:serialize-hidden and can-find(first listfield where columnBuffer = hField:name) then
         do:
           assign
               pSelectedList = replace(( "," + pSelectedList + "," ),( "," + hField:name + "," ),",")
               pSelectedList = trim(pSelectedList,",")
               pSelectedList = replace(( "," + pSelectedList + "," ),( "," + cLabel + "," ),",")
               pSelectedList = trim(pSelectedList,",")
               .
         end.
        
        /* if the label is the same as the name or */
        /* if the column has the serialize-hidden attribute set or */
        /* if the field is not in the user column list already */
        if cLabel = hField:name or hField:serialize-hidden or can-find(first listfield where columnBuffer = hField:name)
         then next.
        
        /* exclude fields */
        &if defined(excludeField) <> 0 &then
        if lookup(hField:name, {&excludeField}) > 0
         then next.
        &endif
        
        /* put the column into the available column list */
        pAvailableList = addDelimiter(pAvailableList, ",") + replace(cLabel, "!", " ") + "," + hField:name.
      end.
  end.
  
  /* cleanup handles */
  delete object hBuffer no-error.
  delete object hField no-error.
  
  /* run the window to allow the user to select the columns */
  std-lo = false.
  run dialogcolumnselect.w (substring(source-procedure:name, index(source-procedure:name, "/") + 1), pAvailableList, input-output pSelectedList, output std-lo).
  
  /* if the user didn't cancel, save the columns in their configuration file */
  if not std-lo
   then publish "SetDynamicBrowseColumns" (substring(source-procedure:name, index(source-procedure:name, "/") + 1), pSelectedList).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetDynamicBrowseColumnWidth Include 
PROCEDURE SetDynamicBrowseColumnWidth :
/*------------------------------------------------------------------------------
@description Sets the initial resize column value
------------------------------------------------------------------------------*/
  /* parameters */
  define input parameter pColumn as character no-undo.
  
  /* variables used to hold the handles */
  define variable hBrowse as handle no-undo.
  define variable hColumn as handle no-undo.
  
  /* set the column width */
  hBrowse = getBrowseHandle().
  if valid-handle(hBrowse) and hBrowse:type = "BROWSE"
   then
    do:
      hColumn = hBrowse:first-column.
      do while valid-handle(hColumn):
        if hColumn:name = pColumn
         then dDynanicBrowseColumnWidth = hColumn:width-pixels.
        hColumn = hColumn:next-column.
      end.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getBrowseHandle Include 
FUNCTION getBrowseHandle RETURNS WIDGET-HANDLE
  (  ) :
/*------------------------------------------------------------------------------
@description Gets the browse handle
------------------------------------------------------------------------------*/
  /* variable used to hold the widget handle */
  define variable hWidget as widget-handle no-undo.
  
  /* variable used to decide if the widget is found or not */
  define variable lFound  as logical       no-undo initial false.

  /* find the widget */
  hWidget = hDynamicBrowseFrame:first-child:first-child.
  repeat while valid-handle(hWidget) and not lFound:
    if hWidget:type = "BROWSE"
     then lFound = true.
     else hWidget = hWidget:next-sibling.
  end.
  
  RETURN hWidget.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getBrowseWidth Include 
FUNCTION getBrowseWidth RETURNS DECIMAL
  (  ) :
/*------------------------------------------------------------------------------
@description Get the total width of the browse colums
------------------------------------------------------------------------------*/
  /* variable used to hold the width of the columns */
  define variable dTotalWidth as decimal no-undo.
  
  /* buffers */
  define buffer listfield for listfield.
  
  /* get the original column widths */
  for each listfield no-lock:
    dTotalWidth = dTotalWidth + (listfield.columnWidth * session:pixels-per-column + 5.9).
  end.
  
  RETURN dTotalWidth.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getKeyfield Include 
FUNCTION getKeyfield RETURNS CHARACTER
  (  ) :
/*------------------------------------------------------------------------------
@description Decide if the browse columns are too big for the frame
------------------------------------------------------------------------------*/
  
  define variable hBrowse   as handle    no-undo.
  define variable hQuery    as handle    no-undo.
  define variable hBuffer   as handle    no-undo.
  define variable pKeyfield as character no-undo initial "".

  if can-find(first {&table})
   then
    do:
      hBrowse = getBrowseHandle().
      if valid-handle(hBrowse) and hBrowse:type = "BROWSE"
       then
        do:
          assign
            hQuery    = hBrowse:query
            hBuffer   = hQuery:get-buffer-handle(1)
            .
          if hQuery:num-results > 0
           then pKeyfield = hBuffer:buffer-field("keyfield"):buffer-value().
        end.
    end.
  RETURN pKeyfield.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isBrowseTooBig Include 
FUNCTION isBrowseTooBig RETURNS LOGICAL
  (  ) :
/*------------------------------------------------------------------------------
@description Decide if the browse columns are too big for the frame
------------------------------------------------------------------------------*/
  RETURN hDynamicBrowseFrame:width-pixels < getBrowseWidth().   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

