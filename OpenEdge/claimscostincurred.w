&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------
*/


CREATE WIDGET-POOL.


{lib/std-def.i}
{lib/add-delimiter.i}
{lib/get-last-day.i}

{tt/claimcostsincurred.i &tableAlias="data"}
{tt/claimcostsincurred.i &tableAlias="tempdata"}
{tt/agent.i}
{tt/state.i}

define variable dStartTime as datetime no-undo.
define variable tAgentID as char no-undo.
define variable tAgentName as char no-undo.

/* variables needed for the browse total */
/* def var totalCol as decimal extent no-undo.       */
/* def var totalAdded as logical no-undo init false. */
/*                                                   */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fMain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bClear bConfig bGo tStartDate tEndDate ~
cmbState tAgent fOver fZeroCost fAdmin RECT-37 RECT-38 
&Scoped-Define DISPLAYED-OBJECTS tStartDate tEndDate cmbState tAgent fOver ~
fZeroCost fAdmin 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD clearData C-Win 
FUNCTION clearData RETURNS LOGICAL PRIVATE
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD createQuery C-Win 
FUNCTION createQuery RETURNS CHARACTER
  ( input pSortColumn as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD doFilterSort C-Win 
FUNCTION doFilterSort RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bClear  NO-FOCUS
     LABEL "Clear" 
     SIZE 7.2 BY 1.71.

DEFINE BUTTON bConfig  NO-FOCUS
     LABEL "Config" 
     SIZE 7.2 BY 1.71.

DEFINE BUTTON bExport  NO-FOCUS
     LABEL "Export" 
     SIZE 7.2 BY 1.71 TOOLTIP "Export".

DEFINE BUTTON bGo  NO-FOCUS
     LABEL "Go" 
     SIZE 7.2 BY 1.71 TOOLTIP "Fetch data".

DEFINE VARIABLE cmbState AS CHARACTER FORMAT "X(256)":U 
     LABEL "State" 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN-LIST
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE fAdmin AS CHARACTER FORMAT "X(256)":U INITIAL "ALL" 
     LABEL "Administrator" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN-LIST
     SIZE 32 BY 1 NO-UNDO.

DEFINE VARIABLE tAgent AS CHARACTER INITIAL "ALL" 
     LABEL "Agent" 
     VIEW-AS COMBO-BOX INNER-LINES 20
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN AUTO-COMPLETION
     SIZE 52 BY 1 NO-UNDO.

DEFINE VARIABLE fOver AS INTEGER FORMAT "->,>>>,>>9":U INITIAL -9999999 
     LABEL "Cost Incurred Over" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE tEndDate AS DATETIME FORMAT "99/99/99":U 
     LABEL "Ending Received Date" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FONT 1 NO-UNDO.

DEFINE VARIABLE tStartDate AS DATETIME FORMAT "99/99/99":U 
     LABEL "Starting Received Date" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FONT 1 NO-UNDO.

DEFINE RECTANGLE RECT-37
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 134 BY 3.33.

DEFINE RECTANGLE RECT-38
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 55.4 BY 3.33.

DEFINE VARIABLE fZeroCost AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fMain
     bClear AT ROW 2.05 COL 112.4 WIDGET-ID 20 NO-TAB-STOP 
     bConfig AT ROW 2.05 COL 127.2 WIDGET-ID 108 NO-TAB-STOP 
     bExport AT ROW 2.05 COL 119.8 WIDGET-ID 94 NO-TAB-STOP 
     bGo AT ROW 2.05 COL 105 WIDGET-ID 16 NO-TAB-STOP 
     tStartDate AT ROW 2.14 COL 26 COLON-ALIGNED WIDGET-ID 6
     tEndDate AT ROW 3.33 COL 26 COLON-ALIGNED WIDGET-ID 8
     cmbState AT ROW 2.14 COL 49 COLON-ALIGNED WIDGET-ID 10
     tAgent AT ROW 3.33 COL 49 COLON-ALIGNED WIDGET-ID 84
     fOver AT ROW 2.05 COL 154.8 COLON-ALIGNED WIDGET-ID 104
     fZeroCost AT ROW 2.19 COL 186.2 WIDGET-ID 110
     fAdmin AT ROW 3.24 COL 154.8 COLON-ALIGNED WIDGET-ID 100
     "Parameters" VIEW-AS TEXT
          SIZE 11 BY .62 AT ROW 1.24 COL 3 WIDGET-ID 4
     "Filters" VIEW-AS TEXT
          SIZE 6 BY .62 AT ROW 1.24 COL 136.8 WIDGET-ID 98
     "Show Zero:" VIEW-AS TEXT
          SIZE 11 BY .62 AT ROW 2.29 COL 174.2 WIDGET-ID 112
     RECT-37 AT ROW 1.48 COL 2 WIDGET-ID 2
     RECT-38 AT ROW 1.48 COL 135.8 WIDGET-ID 96
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 199 BY 28.05 WIDGET-ID 100.

DEFINE FRAME fBrowse
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 2 ROW 5.05
         SIZE 197 BY 23.57 WIDGET-ID 200.


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
         TITLE              = "Claim Costs Incurred"
         HEIGHT             = 27.95
         WIDTH              = 199
         MAX-HEIGHT         = 47.38
         MAX-WIDTH          = 384
         VIRTUAL-HEIGHT     = 47.38
         VIRTUAL-WIDTH      = 384
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
/* REPARENT FRAME */
ASSIGN FRAME fBrowse:FRAME = FRAME fMain:HANDLE.

/* SETTINGS FOR FRAME fBrowse
                                                                        */
/* SETTINGS FOR FRAME fMain
   FRAME-NAME Custom                                                    */

DEFINE VARIABLE XXTABVALXX AS LOGICAL NO-UNDO.

ASSIGN XXTABVALXX = FRAME fBrowse:MOVE-AFTER-TAB-ITEM (fAdmin:HANDLE IN FRAME fMain)
/* END-ASSIGN-TABS */.

/* SETTINGS FOR BUTTON bExport IN FRAME fMain
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fMain:HANDLE
       ROW             = 3.86
       COLUMN          = 105.2
       HEIGHT          = .48
       WIDTH           = 28.8
       TAB-STOP        = no
       WIDGET-ID       = 90
       HIDDEN          = no
       SENSITIVE       = no.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {35053A22-8589-11D1-B16A-00C0F0283628} type: ProgressBar */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Claim Costs Incurred */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Claim Costs Incurred */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Claim Costs Incurred */
DO:
  run windowResized in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bClear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bClear C-Win
ON CHOOSE OF bClear IN FRAME fMain /* Clear */
DO:
  clearData().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bConfig
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bConfig C-Win
ON CHOOSE OF bConfig IN FRAME fMain /* Config */
DO:
  run SetDynamicBrowseColumns.
  run windowResized in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bExport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bExport C-Win
ON CHOOSE OF bExport IN FRAME fMain /* Export */
DO:
  run exportData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bGo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bGo C-Win
ON CHOOSE OF bGo IN FRAME fMain /* Go */
do:
    def var validDate as date no-undo.
    validDate = ?.
    validDate = date(tStartDate:screen-value).

    if validDate = ?
       then
          do:
             message "Start date is blank!" view-as alert-box warning.
             return.
          end.

     validDate = ?.
     validDate = date(tEndDate:screen-value).
     if validDate = ?
          then
            do:
               message "End date is blank!" view-as alert-box warning.
               return.
            end.

    run getData in this-procedure.
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cmbState
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cmbState C-Win
ON VALUE-CHANGED OF cmbState IN FRAME fMain /* State */
DO:
  clearData().
  run AgentComboState in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fAdmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fAdmin C-Win
ON VALUE-CHANGED OF fAdmin IN FRAME fMain /* Administrator */
DO:
  dataSortDesc = NOT dataSortDesc.
  RUN sortData IN THIS-PROCEDURE (dataSortBy).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fOver
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fOver C-Win
ON LEAVE OF fOver IN FRAME fMain /* Cost Incurred Over */
do:
  apply "VALUE-CHANGED" to fAdmin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fOver C-Win
ON RETURN OF fOver IN FRAME fMain /* Cost Incurred Over */
do:
  apply "LEAVE" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fZeroCost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fZeroCost C-Win
ON VALUE-CHANGED OF fZeroCost IN FRAME fMain
DO:
  apply "VALUE-CHANGED" to fAdmin.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tAgent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tAgent C-Win
ON VALUE-CHANGED OF tAgent IN FRAME fMain /* Agent */
DO:
  clearData().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */


/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

{lib/win-main.i}
{lib/win-status.i &entity="'Claim'"}
{lib/brw-main.i}
{lib/report-progress-bar.i}
{lib/set-buttons.i}
{lib/set-filters.i &tableName="'tempdata'" &labelName="'Admin'" &columnName="'assignedTo'" &noSort=true}
{lib/build-dynamic-browse.i &table=data &entity="'CostsIncurred'" &keyfield="'claimID'" &integerOnly=true &resizeColumn="'agentName,category,cause'"}

{&window-name}:max-width-pixels = session:width-pixels.
{&window-name}:max-height-pixels = session:height-pixels.
{&window-name}:min-width-pixels = {&window-name}:width-pixels.
{&window-name}:min-height-pixels = {&window-name}:height-pixels.

{&window-name}:window-state = 2.
initializeStatusWindow({&window-name}:handle).

/* load the data for the state filter */

session:immediate-display = yes.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  
  do with FRAME {&frame-name}:
    {lib/get-state-list.i &combo=cmbState &addAll=true}
    {lib/get-agent-list.i &combo=tAgent &state=cmbState &addAll=true}
    /* set the state and the agent */
    {lib/set-current-value.i &state=cmbState &agent=tAgent}
    
    clearData().
    run SetDynamicBrowseColumnWidth ("agentName").
    setFilterCombos("ALL").
    
    tStartDate:screen-value = string(date(1, 1, year(today))).
    tEndDate:screen-value = string(date(month(today), getLastDay(today), year(today))).
    {&window-name}:window-state = 3.
  end.
  
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buildFieldList C-Win 
PROCEDURE buildFieldList :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  run BuildDynamicBrowseColumns.
  for each listfield exclusive-lock
     where listfield.dataType = "character":
    
    case listfield.columnBuffer:
     when "claimID" then listfield.columnWidth = 12.
     when "assignedTo" then listfield.columnWidth = 20.
     when "agentID" or
     when "altaRisk" or 
     when "altaResponsibility" then listfield.columnWidth = 12.
     when "agentName" or
     when "category" or 
     when "cause" then listfield.columnWidth = 41.
     when "stateID" then listfield.columnWidth = 8.
    end case.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control_load C-Win  _CONTROL-LOAD
PROCEDURE control_load :
/*------------------------------------------------------------------------------
  Purpose:     Load the OCXs    
  Parameters:  <none>
  Notes:       Here we load, initialize and make visible the 
               OCXs in the interface.                        
------------------------------------------------------------------------------*/

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.

OCXFile = SEARCH( "claimscostincurred.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).

IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
  RUN initialize-controls IN THIS-PROCEDURE NO-ERROR.
END.
ELSE MESSAGE "claimscostincurred.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

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
  RUN control_load.
  DISPLAY tStartDate tEndDate cmbState tAgent fOver fZeroCost fAdmin 
      WITH FRAME fMain IN WINDOW C-Win.
  ENABLE bClear bConfig bGo tStartDate tEndDate cmbState tAgent fOver fZeroCost 
         fAdmin RECT-37 RECT-38 
      WITH FRAME fMain IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fMain}
  VIEW FRAME fBrowse IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fBrowse}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE exportData C-Win 
PROCEDURE exportData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define variable hBrowse as handle no-undo.
  define variable tFullFile as character no-undo.

  hBrowse = getBrowseHandle().
  if valid-handle(hBrowse) and hBrowse:type = "BROWSE"
   then
    do:
      std-ha = hBrowse:query.
      if std-ha:num-results = 0
       then
        do:
          message "No results to export" view-as alert-box warning buttons ok.
          return.
        end.
    end.

  do with frame {&frame-name}:
     tFullFile = "claim_costs_incurred_" + replace(string(tStartDate:input-value,"99/99/9999"),"/","_") + "_to_" + replace(string(tEndDate:input-value,"99/99/9999"),"/","_").
  end.
  
  std-ch = "C".
  publish "GetExportType" (output std-ch).
  if std-ch = "X" 
   then run util/exporttoexcelbrowse.p (string(hBrowse), tFullFile).
   else run util/exporttocsvbrowse.p (string(hBrowse), tFullFile).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getData C-Win 
PROCEDURE getData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  def var tSuccess as logical init false no-undo.
  def var tMsg as char no-undo.

  clearData().

  do with frame {&frame-name}:
    tAgentID = tAgent:input-value.
    tAgentName = "".
    if tAgentID = "ALL"
     then 
      assign 
        tAgentID = ""
        tAgentName = ""
        .
  end.

  for first agent no-lock
      where agent.agentID = tAgentID:
    
    tAgentName = agent.name.
  end.

  dStartTime = now.
  run server/getclaimcostsincurred.p (tStartDate:input-value,
                                      tEndDate:input-value,
                                      cmbState:input-value,
                                      0,
                                      tAgentID,
                                      tAgentName,
                                      output table data,
                                      output tSuccess,
                                      output tMsg).
   
  if not tSuccess
   then message tMsg view-as alert-box warning.
   else
    do:
      for each data exclusive-lock:
        publish "GetSysUserName" (data.assignedTo, output data.assignedToName).
        publish "GetSysPropDesc" ("AMD", "Agent", "Status", data.agentStatus, output data.agentStatusDesc).
        publish "GetSysPropDesc" ("CLM", "ClaimDescription", "Status", data.claimStatus, output data.claimStatusDesc).
      end.
      run SetProgressStatus.
      dataSortDesc = false.
      run sortData in this-procedure ("claimID").

      appendStatus("in " + trim(string(interval(now, dStartTime, "milliseconds") / 1000, ">>>,>>9.9")) + " seconds").
      displayStatus().
    end.
  run SetProgressEnd.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sortData C-Win 
PROCEDURE sortData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pSortColumn as character no-undo.
  define variable hBrowse as handle no-undo.
  define variable hQuery as handle no-undo.
  define variable hBuffer as handle no-undo.
  define variable hTable as handle no-undo.

  run buildFieldList in this-procedure.
  run BuildDynamicBrowse (createQuery(dataSortBy)).
  run BuildDynamicBrowseTotalRow (createQuery(dataSortBy)).
  enableButtons(can-find(first data)).
  enableFilters(can-find(first data)).
  
  hBrowse = getBrowseHandle().
  if valid-handle(hBrowse) and hBrowse:type = "BROWSE"
   then
    do:
      std-ha = hBrowse:query.
      setStatusCount(std-ha:num-results).
    end.
  
  empty temp-table tempdata.
  create buffer hBuffer for table "data".
  create buffer hTable for table "tempdata".
  create query hQuery.
  hQuery:set-buffers(hBuffer).
  hQuery:query-prepare("for each data no-lock " + doFilterSort()).
  hQuery:query-open().
  hQuery:get-first().
  repeat while not hQuery:query-off-end:
    hTable:buffer-create.
    hTable:buffer-copy(hBuffer).
    hQuery:get-next().
  end.
  hQuery:query-close().
  setFilterCombos("ALL").
  
  delete object hQuery.
  delete object hBuffer.
  delete object hTable.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE windowResized C-Win 
PROCEDURE windowResized :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  frame {&frame-name}:width-pixels = {&window-name}:width-pixels.
  frame {&frame-name}:virtual-width-pixels = {&window-name}:width-pixels.
  frame {&frame-name}:height-pixels = {&window-name}:height-pixels.
  frame {&frame-name}:virtual-height-pixels = {&window-name}:height-pixels.
 
  /* modify the frame for the dynamic browse */
  frame fBrowse:width-pixels = {&window-name}:width-pixels - 10.
  frame fBrowse:virtual-width-pixels = frame fBrowse:width-pixels.
  frame fBrowse:height-pixels = {&window-name}:height-pixels - frame fBrowse:y - 5.
  frame fBrowse:virtual-height-pixels = frame fBrowse:height-pixels.
  
  run buildFieldList in this-procedure.
  dataSortDesc = not dataSortDesc.
  run BuildDynamicBrowse (createQuery(dataSortBy)).
  run BuildDynamicBrowseTotalRow (createQuery(dataSortBy)).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION clearData C-Win 
FUNCTION clearData RETURNS LOGICAL PRIVATE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  empty temp-table data.
  enableButtons(false).
  enableFilters(false).
  run windowResized in this-procedure.
  clearStatus().

  RETURN true.   /* Function return value. */
  
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION createQuery C-Win 
FUNCTION createQuery RETURNS CHARACTER
  ( input pSortColumn as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  if pSortColumn = dataSortBy
   then dataSortDesc = not dataSortDesc.
  
  if pSortColumn = ""
   then return "preselect each data no-lock " + doFilterSort().
   else return "preselect each data no-lock " + doFilterSort() + " by " + pSortColumn + (if dataSortDesc then " descending" else "").

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION doFilterSort C-Win 
FUNCTION doFilterSort RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable tWhereClause as character no-undo.
  
  define variable tAdmin as character no-undo.
  define variable tZeroCost as logical no-undo.
  define variable tSubQuery as character no-undo.
  define variable tOperand as character no-undo.
  
  do with frame {&frame-name}:
    assign
      tAdmin = fAdmin:screen-value
      tAdmin = (if tAdmin = ? or tAdmin = "" then "ALL" else tAdmin)
      tZeroCost = fZeroCost:checked
      tOperand = if tZeroCost then "=" else "<>"
      .
  end.
  
  /* build the subquery */
  if tZeroCost
   then
    assign
      tSubQuery = addDelimiter(tSubQuery, " and ") + "laePosted = 0"
      tSubQuery = addDelimiter(tSubQuery, " and ") + "lossPosted = 0"
      tSubQuery = addDelimiter(tSubQuery, " and ") + "laeBalance = 0"
      tSubQuery = addDelimiter(tSubQuery, " and ") + "lossBalance = 0"
      tSubQuery = addDelimiter(tSubQuery, " and ") + "costsIncurred = 0"
      .
   else
    assign
      tSubQuery = addDelimiter(tSubQuery, " or ") + "laePosted <> 0"
      tSubQuery = addDelimiter(tSubQuery, " or ") + "lossPosted <> 0"
      tSubQuery = addDelimiter(tSubQuery, " or ") + "laeBalance <> 0"
      tSubQuery = addDelimiter(tSubQuery, " or ") + "lossBalance <> 0"
      tSubQuery = addDelimiter(tSubQuery, " or ") + "costsIncurred <> 0"
      .

  /* build the query */
  do with frame {&frame-name}:
    if tAdmin <> "ALL"
     then tWhereClause = addDelimiter(tWhereClause," and ") + "assignedTo = '" + tAdmin + "'".
    if not tZeroCost
     then tWhereClause = addDelimiter(tWhereClause," and ") + "(costsIncurred > " + string(fOver:input-value) + " and (" + tSubQuery + "))".
     else tWhereClause = addDelimiter(tWhereClause," and ") + "(costsIncurred > " + string(fOver:input-value) + " or (" + tSubQuery + "))".
    tWhereClause = "where " + tWhereClause.
  end.

  return tWhereClause.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

