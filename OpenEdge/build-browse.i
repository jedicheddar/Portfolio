&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*---------------------------------------------------------------------
@name build-browse.i
@description Procedure BuildBrowse to build a dynamic browse from a
             dynamic temp table

@author John Oliver
@version 1.0
@created 09/14/16
@modified 09/23/22  SC Task #99127 Removed sorting on claimnotes because of indexing error
@notes 
---------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{lib/std-def.i}
{lib/add-delimiter.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
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

do:
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BuildBrowse Include 
PROCEDURE BuildBrowse :
/*------------------------------------------------------------------------------
@description Build the dynamic browse
@param Table;handle;The table data handle
@param Field;handle;The fields for the table data
@param Frame;handle;The frame that will hold the browse
@param Entity;char;The underlying entity for the table data
------------------------------------------------------------------------------*/
  define input parameter hTable as handle no-undo.
  define input parameter hField as handle no-undo.
  define input parameter hFrame as handle no-undo.
  define input parameter pEntity as character no-undo.
  define variable iFieldCount as integer no-undo initial 0.
  define variable hBrowse as handle no-undo.
  define variable hQuery as handle no-undo.
  define variable hTableBuffer as handle no-undo.
  define variable hFieldBuffer as handle no-undo.
  define variable iWidth as integer no-undo initial 0.
  define variable cBrowseName as character no-undo initial "brwData".
  define variable iHasInteger as logical no-undo initial false.
  
  /* reset the column handle list */
  colHandleList = "".
  
  /* delete the old browse if there is one */
  hBrowse = GetWidgetByName(hFrame,cBrowseName).
  if hBrowse <> ?
   then delete widget hBrowse.
  
  /* build the result browse */
  hTableBuffer = hTable:default-buffer-handle.
  hFieldBuffer = hField:default-buffer-handle.
  create query hQuery.
  hQuery:set-buffers(hTableBuffer).
  hQuery:query-prepare("preselect each " + hTableBuffer:table).
  hQuery:query-open().
  create browse hBrowse
  assign
    &if defined(noTitle) = 0 &then
    title                  = "Results"
    &endif
    frame                  = hFrame
    query                  = hQuery
    name                   = cBrowseName
    column                 = 1.0
    row                    = 1.0
    width-chars            = hFrame:width-chars
    height-chars           = hFrame:height-chars
    row-height-chars       = 0.81
    row-markers            = false
    fit-last-column        = true
    font                   = 1
    column-resizable       = true
    column-movable         = false
    allow-column-searching = true
    visible                = true 
    sensitive              = true 
    read-only              = true
    separators             = true
    triggers:
      on row-display persistent run DynamicRowDisplay in this-procedure (hQuery).
      on start-search persistent run DynamicSortData in this-procedure (hBrowse, hQuery, pEntity).
      on default-action persistent run DynamicRowClick in this-procedure (hTableBuffer, pEntity).
      on value-changed persistent run DynamicRowChange in this-procedure (hTableBuffer, pEntity).
    end triggers.
    .
  create query hQuery.
  hQuery:set-buffers(hFieldBuffer).
  hQuery:query-prepare("preselect each " + hFieldBuffer:table).
  hQuery:query-open().
  hQuery:get-first().
  /* loop through the field buffer */
  repeat while not hQuery:query-off-end:
    /* set the column label and width */
    iFieldCount = iFieldCount + 1.
    std-ch = hFieldBuffer:buffer-field("columnBuffer"):buffer-value().
    if hFieldBuffer:buffer-field("dataType"):buffer-value() = "logical"
     then std-ha = hBrowse:add-like-column(hTableBuffer:table + "." + std-ch, iFieldCount, "TOGGLE-BOX").
     else std-ha = hBrowse:add-like-column(hTableBuffer:table + "." + std-ch).
    assign
      iHasInteger = (iHasInteger or hFieldBuffer:buffer-field("dataType"):buffer-value() = "integer")
      std-ha:label = hFieldBuffer:buffer-field("displayName"):buffer-value()
      std-ha:width = hFieldBuffer:buffer-field("columnWidth"):buffer-value()
      iWidth = iWidth + std-ha:width
      colHandleList = addDelimiter(colHandleList,",") + string(std-ha)
      .
    /* if there are less columns than can fit in the browse view */
    /* the wierd formula is because the browse widget columns */
    /* add a value every time a new column is added so we need to offset the value */
    if iWidth < hBrowse:width and (iFieldCount = hTableBuffer:num-fields - 1 or hTableBuffer:num-fields = 1)
     then std-ha:width = hBrowse:width - (iWidth - std-ha:width) - ((if iHasInteger then 6 else 5) + ((iFieldCount - 1) * 0.75)).
    hQuery:get-next().
  end.
    
  /* the following is to fix a bug with the row display on a dynamic browse */
  /* for some reason, the last column of the first "page" will not be highlighted */
  /* and pressing the HOME key fixes the row column highlighting */
  apply "HOME":U to hBrowse.
  
  run DynamicPopupMenu in this-procedure (hBrowse).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicSortData Include 
PROCEDURE DynamicExportData :
/*------------------------------------------------------------------------------
@description Exports the data in the browse
------------------------------------------------------------------------------*/
  run ExportData in this-procedure no-error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicSortData Include 
PROCEDURE DynamicPopupMenu :
/*------------------------------------------------------------------------------
@description Creates a dynamic popup menu for exporting the data
@param Browse;handle;The handle to the browse widget
------------------------------------------------------------------------------*/
  define input parameter hBrowse as handle no-undo.
  define variable hQuery as handle no-undo.
  define variable hPopup as handle no-undo.
  define variable hItem as handle no-undo.
  
  hQuery = hBrowse:query.
   
  create menu hPopup
  assign
    popup-only = true
    .
    
  create menu-item hItem
  assign
    label     = "Export Data"
    name      = "m_Export_Data"
    sensitive = (hQuery:num-results > 0)
    parent    = hPopup
    triggers:
      on choose persistent run DynamicExportData in this-procedure.
    end triggers
    .
  publish "AddDynamicPopupMenu" (hPopup, (hQuery:num-results > 0)).
    
  hBrowse:popup-menu = hPopup.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicRowClick Include 
PROCEDURE DynamicRowChange :
/*------------------------------------------------------------------------------
@description Publishes a procedure to perform an action when the browse changes
             rows.
------------------------------------------------------------------------------*/
  define input parameter hBuffer as handle no-undo.
  define input parameter pEntity as character no-undo.
  
  publish pEntity + "RowChanged" (hBuffer:buffer-field("keyfield"):buffer-value()).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicRowClick Include 
PROCEDURE DynamicRowClick :
/*------------------------------------------------------------------------------
@description Publishes a procedure to perform an action when the user double-clicks
             a row
------------------------------------------------------------------------------*/
  define input parameter hBuffer as handle no-undo.
  define input parameter pEntity as character no-undo.
  
  publish pEntity + "Selected" (hBuffer:buffer-field("keyfield"):buffer-value()).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicRowDisplay Include 
PROCEDURE DynamicRowDisplay :
/*------------------------------------------------------------------------------
@description Displays the rows by alternating color
------------------------------------------------------------------------------*/
  define input parameter hQuery as handle no-undo.
  
  if hQuery:current-result-row modulo 2 = 0
   then
    do std-in = 1 to num-entries(colHandleList):
      colHandle = handle(entry(std-in, colHandleList)).
      if valid-handle(colHandle)
       then colHandle:bgcolor = {&evenColor}.
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynamicSortData Include 
PROCEDURE DynamicSortData :
/*------------------------------------------------------------------------------
@description Sorts the data for the browse
------------------------------------------------------------------------------*/
  define input parameter hBrowse as handle no-undo.
  define input parameter hQuery as handle no-undo.
  define input parameter pEntity as character no-undo.
  
  define variable lFoundBy as logical no-undo initial false.
  define variable tQuery as character no-undo.
  
  if valid-handle(hBrowse) and valid-handle(hQuery)
   then
    do:
      hBrowse:clear-sort-arrows().
      hSortColumn = hBrowse:current-column.
      if hSortColumn:name = dataSortBy 
       then dataSortDesc = not dataSortDesc.
       
      std-ch = hQuery:prepare-string.
      do std-in = 1 to num-entries(std-ch, " "):
        if index(entry(std-in, std-ch, " "), "by") > 0
         then lFoundBy = true.
        
        if not lFoundBy
         then tQuery = addDelimiter(tQuery, " ") + entry(std-in, std-ch, " ").
      end.
          
      if hSortColumn:name ne 'claimnote_notes' 
       then
        do:
          tQuery = tQuery + " by " + hSortColumn:name + (if dataSortDesc then " descending" else "").

          do std-in = 1 to num-entries(colHandleList):
            colHandle = handle(entry(std-in, colHandleList)).
            if valid-handle(colHandle) and colHandle:name = hSortColumn:name
             then hBrowse:set-sort-arrow(std-in, not dataSortDesc).
          end.
          dataSortBy = hSortColumn:name.
        end.
         
      hQuery:query-close().
      hQuery:query-prepare(tQuery).
      hQuery:query-open().
      run DynamicRowChange in this-procedure (hQuery:get-buffer-handle(1), pEntity).
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

