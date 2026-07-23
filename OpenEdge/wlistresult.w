&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------
@name wrptbuilder.w
@description The screen is used to get data from the database at an ad-hoc
             basis by adding the columns and criteria

@author John Oliver
@created 01/07/2015
@notes Due to how progress creates widgets, the name of the widget 
       cannot be renamed once created without additional difficulty. So, 
       even when deleting a row, the name stays the same while the 
       display changes. There are two different variables that control 
       the values.
----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

{lib/std-def.i}
{lib/find-widget.i}
{lib/build-browse.i}
{tt/listentity.i}
{tt/listfield.i}
{tt/listentity.i &tableAlias="userentity"}
{tt/listfield.i &tableAlias="userfield"}
{tt/listfilter.i &tableAlias="userfilter"}

define input parameter pDisplayName as character no-undo.
define input parameter pReportName as character no-undo.

/* dynamic results */
define variable listresult as handle no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmBrowse

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetResultCount C-Win 
FUNCTION GetResultCount RETURNS INTEGER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmBrowse
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 136 BY 24.47 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "List Results"
         HEIGHT             = 24.48
         WIDTH              = 136
         MAX-HEIGHT         = 46.24
         MAX-WIDTH          = 246.6
         VIRTUAL-HEIGHT     = 46.24
         VIRTUAL-WIDTH      = 246.6
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME frmBrowse
   FRAME-NAME                                                           */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* List Results */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* List Results */
DO:
  run WindowResized in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

{lib/win-main.i}
{&window-name}:min-height-pixels = {&window-name}:height-pixels.
{&window-name}:min-width-pixels = {&window-name}:width-pixels.
{&window-name}:max-height-pixels = session:height-pixels.
{&window-name}:max-width-pixels = session:width-pixels.

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

subscribe to "ExportData" anywhere.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
  {&window-name}:title = "Report: " + pDisplayName.
  RUN enable_UI.
  run Initialize in this-procedure (pReportName).
      
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ClearData C-Win 
PROCEDURE ClearData :
/*------------------------------------------------------------------------------
@description Clears any selections that the user may have made   
------------------------------------------------------------------------------*/  
  /* empty the temporary tables */
  empty temp-table userentity.
  empty temp-table userfilter.
  empty temp-table userfield.
  
  for first listentity no-lock:
    std-ch = listentity.entityName.
  end.
  
  /* rebuild the browse */
  publish "BuildEmptyTable" (std-ch, output listresult, output table userfield).
  run BuildBrowse in this-procedure (listresult,
                                     temp-table userfield:handle,
                                     frame frmBrowse:handle,
                                     std-ch).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  VIEW FRAME frmBrowse IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmBrowse}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ExportData C-Win 
PROCEDURE ExportData :
/*------------------------------------------------------------------------------
@description Exports the result     
------------------------------------------------------------------------------*/
  define variable cReportName as character no-undo.
  
  cReportName = "Report_" + pReportName.
  
  std-ha = frame frmBrowse:first-child:first-child.
  if valid-handle(std-ha) and std-ha:type = "browse"
   then 
    do:
      {&window-name}:always-on-top = false.
      if GetResultCount() > 0
       then
        do:
         std-ch = "C".
         publish "GetExportType" (output std-ch).
         if std-ch = "X" 
          then run util/exporttoexcelbrowse.p (string(std-ha:handle), cReportName).
          else run util/exporttocsvbrowse.p (string(std-ha:handle), cReportName).
        end.
       else message "No results to export" view-as alert-box warning buttons ok.
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetData C-Win 
PROCEDURE GetData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pReportName as character no-undo.
  
  /* get the action for the table */
  publish "OpenList" (pReportName,
                      output table userfield,
                      output table userfilter,
                      output std-lo).
                      
  for each listentity, first userfield no-lock
     where listentity.entityName = userfield.entityName:
    
    std-ch = listentity.entityName.
    publish "GetEntityFields" (std-ch, output table listfield).
    
    create userentity.
    buffer-copy listentity to userentity.
  end.
  
  for each userfield, first listfield exclusive-lock
     where userfield.tableName = listfield.tableName
       and userfield.columnBuffer = listfield.columnBuffer:
       
    assign
      userfield.displayName = listfield.displayName
      userfield.columnBuffer = listfield.columnBuffer
      userfield.columnWidth = listfield.columnWidth
      userfield.columnFormat = listfield.columnFormat
      userfield.dataType = listfield.dataType
      .
  end.

  /* run the report */
  publish "LoadListData" (table userentity,
                          table userfield,
                          table userfilter,
                          output listresult,
                          output std-lo).
  
  /* build the result browse */
  if std-lo
   then 
    do:
      run BuildBrowse in this-procedure (listresult,
                                         temp-table userfield:handle,
                                         frame frmBrowse:handle,
                                         std-ch).
      status input string(GetResultCount()) + " row(s) returned".
      status default string(GetResultCount()) + " row(s) returned".
    end.
   else message "Could not retrieve report data" view-as alert-box error buttons ok.
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialize C-Win 
PROCEDURE Initialize :
/*------------------------------------------------------------------------------
@description Sets the window on the initial open  
------------------------------------------------------------------------------*/
  define input parameter pReportName as character no-undo.
  
  /* get the allowed tables for the user */
  publish "GetEntities" (output table listentity,
                         output std-lo).
  
  if std-lo
   then
    do:
      run ClearData in this-procedure.
      run GetData in this-procedure (pReportName).
    end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE WindowResized C-Win 
PROCEDURE WindowResized :
/*------------------------------------------------------------------------------
@description Executes when the window is resized, either bigger or smaller 
------------------------------------------------------------------------------*/
  /* modify the frame for the dynamic browse */
  frame frmBrowse:width-pixels = {&window-name}:width-pixels.
  frame frmBrowse:virtual-width-pixels = {&window-name}:width-pixels.
  frame frmBrowse:height-pixels = {&window-name}:height-pixels - frame frmBrowse:y.
  frame frmBrowse:virtual-height-pixels = {&window-name}:height-pixels - frame frmBrowse:y.
  
  /* get the entity name */
  for first userfield:
    std-ch = userfield.entityName.
  end.
  
  /* rebuild the result browse */
  if valid-handle(listresult)
   then run BuildBrowse in this-procedure (listresult,
                                           temp-table userfield:handle,
                                           frame frmBrowse:handle,
                                           std-ch).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetResultCount C-Win 
FUNCTION GetResultCount RETURNS INTEGER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
@description Gets the count of records in the results
------------------------------------------------------------------------------*/
  define variable iCount as integer no-undo initial 0.
  define variable hQuery as handle no-undo.
  
  std-ha = frame frmBrowse:first-child:first-child.
  if valid-handle(std-ha) and std-ha:type = "browse"
   then 
    do:
      /* validate that there is data */
      hQuery = std-ha:query.
      
      iCount = hQuery:num-results.
    end.

  RETURN iCount.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

