&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/* wops05-r.w
   Window of Statutory Liability report.
   Modified:
   Date          Name        Comments
   05/08/2026    SRawat      Task#129379 Increased the format size of Gross Rate and Net Rate to support larger values. 
*/

CREATE WIDGET-POOL.

{tt/period.i}
{tt/state.i}
{tt/statliab.i}
{tt/statliab.i &tableAlias=ttData}

{lib/std-def.i}
{lib/get-column.i}

def var hData as handle no-undo.

def var tStatus as char no-undo.
def var tNumTasks as int no-undo.
def var tCurTask as int no-undo.

def var tGettingData as logical.
def var tKeepGettingData as logical.

def var dColumnWidth as decimal no-undo.

{lib/winlaunch.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fMain
&Scoped-define BROWSE-NAME brwData

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttData

/* Definitions for BROWSE brwData                                       */
&Scoped-define FIELDS-IN-QUERY-brwData ttData.agentID ttData.name ttData.stateID ttData.fileNumber ttData.ownerNum ttData.lenderNum ttData.ownerLiability ttData.lenderLiability ttData.reservableLiability /* ttData.grossPremium */ /* ttData.netPremium */ ttData.grossRate ttData.netRate ttData.grouped   
&Scoped-define ENABLED-FIELDS-IN-QUERY-brwData   
&Scoped-define SELF-NAME brwData
&Scoped-define QUERY-STRING-brwData FOR EACH ttData
&Scoped-define OPEN-QUERY-brwData OPEN QUERY {&SELF-NAME} FOR EACH ttData.
&Scoped-define TABLES-IN-QUERY-brwData ttData
&Scoped-define FIRST-TABLE-IN-QUERY-brwData ttData


/* Definitions for FRAME fMain                                          */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bRefresh fMonth fYear fState brwData ~
tOwnerOnly tSubjectToReserve tAgents tLenderOnly tBatches tOwnerLender ~
tFiles tLenderOwner tPolicies tGrossRate tNetRate 
&Scoped-Define DISPLAYED-OBJECTS fMonth fYear fState 

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD displayTotals C-Win 
FUNCTION displayTotals RETURNS LOGICAL PRIVATE
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD pbMinStatus C-Win 
FUNCTION pbMinStatus RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD pbUpdateStatus C-Win 
FUNCTION pbUpdateStatus RETURNS LOGICAL
  ( input pPercentage   as int,
    input pPauseSeconds as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setReportButtons C-Win 
FUNCTION setReportButtons RETURNS LOGICAL
  ( input pCmd as char )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of handles for OCX Containers                            */
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bExport  NO-FOCUS
     LABEL "Export" 
     SIZE 7.2 BY 1.71 TOOLTIP "Export".

DEFINE BUTTON bPrint  NO-FOCUS
     LABEL "Print" 
     SIZE 7.2 BY 1.71 TOOLTIP "PDF".

DEFINE BUTTON bRefresh  NO-FOCUS
     LABEL "Go" 
     SIZE 7.2 BY 1.71 TOOLTIP "Fetch data".

DEFINE VARIABLE fMonth AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Period" 
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEM-PAIRS "ALL",0
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE fState AS CHARACTER FORMAT "X(256)":U INITIAL "ALL" 
     LABEL "State" 
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN-LIST
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE fYear AS INTEGER FORMAT ">>>9":U INITIAL 2010 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "2010" 
     DROP-DOWN-LIST
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE tAgents AS INTEGER FORMAT "z,zzz,zz9":U INITIAL 0 
     LABEL "Agents" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE tBatches AS INTEGER FORMAT "z,zzz,zz9":U INITIAL 0 
     LABEL "Batches" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE tFiles AS INTEGER FORMAT "z,zzz,zz9":U INITIAL 0 
     LABEL "Files" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE tGrossRate AS DECIMAL FORMAT "-zz,zzz,zzz,zz9.99":U INITIAL 0 
     LABEL "Total Rate" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 TOOLTIP "Total Gross Rate / $1,000 of Liability" NO-UNDO.

DEFINE VARIABLE tLenderOnly AS DECIMAL FORMAT "-zz,zzz,zzz,zz9":U INITIAL 0 
     LABEL "Lender Only" 
     VIEW-AS FILL-IN 
     SIZE 23.2 BY 1 NO-UNDO.

DEFINE VARIABLE tLenderOwner AS DECIMAL FORMAT "-zz,zzz,zzz,zz9":U INITIAL 0 
     LABEL "Lender > Owner" 
     VIEW-AS FILL-IN 
     SIZE 23.2 BY 1 NO-UNDO.

DEFINE VARIABLE tNetRate AS DECIMAL FORMAT "-zz,zzz,zzz,zz9.99":U INITIAL 0 
     LABEL "Net Rate" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 TOOLTIP "Net Rate / $1,000 of Liability" NO-UNDO.

DEFINE VARIABLE tOpenClosed AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE tOwnerLender AS DECIMAL FORMAT "-zz,zzz,zzz,zz9":U INITIAL 0 
     LABEL "Owner => Lender" 
     VIEW-AS FILL-IN 
     SIZE 23.2 BY 1 NO-UNDO.

DEFINE VARIABLE tOwnerOnly AS DECIMAL FORMAT "-zz,zzz,zzz,zz9":U INITIAL 0 
     LABEL "Owner Only" 
     VIEW-AS FILL-IN 
     SIZE 23.2 BY 1 NO-UNDO.

DEFINE VARIABLE tPolicies AS INTEGER FORMAT "z,zzz,zz9":U INITIAL 0 
     LABEL "Policies" 
     VIEW-AS FILL-IN 
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE tSubjectToReserve AS DECIMAL FORMAT "-zz,zzz,zzz,zz9":U INITIAL 0 
     LABEL "Subject to Reserve" 
     VIEW-AS FILL-IN 
     SIZE 27 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-36
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 75 BY 5.24.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY brwData FOR 
      ttData SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE brwData
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS brwData C-Win _FREEFORM
  QUERY brwData DISPLAY
      ttData.agentID label "AgentID" format "x(12)" width 10
 ttData.name label "Name" format "x(250)" width 30
 ttData.stateID label "State" format "x(4)" width 5
 ttData.fileNumber column-label "File!Number" format "x(25)" width 25
 ttData.ownerNum column-label "No. of!Owners" format "->>>9" width 7 
 ttData.lenderNum column-label "No. of!Lenders" format "->>>9" width 7
 ttData.ownerLiability column-label "Owner!Liability" format "-zzz,zzz,zzz,zz9.99"
 ttData.lenderLiability column-label "Lender!Liability" format "-zzz,zzz,zzz,zz9.99"
 ttData.reservableLiability column-label "Liability Subject!to Reserve" format "-zzz,zzz,zzz,zz9.99"
/*  ttData.grossPremium column-label "Gross!Premium" format "-zzz,zzz,zzz,zz9.99" */
/*  ttData.netPremium label "Net!Premium" format "-zzz,zzz,zzz,zz9.99"            */
 ttData.grossRate column-label "Gross!Rate" format "-zzz,zzz,zzz,zz9.99" width 19
 ttData.netRate column-label "Net!Rate" format "-zzz,zzz,zzz,zz9.99" width 19
 ttData.grouped label "Group" format "x(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 206 BY 14.57 ROW-HEIGHT-CHARS .81 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fMain
     bExport AT ROW 2.86 COL 59.6 WIDGET-ID 2 NO-TAB-STOP 
     bPrint AT ROW 2.86 COL 67 WIDGET-ID 14 NO-TAB-STOP 
     bRefresh AT ROW 2.86 COL 52.2 WIDGET-ID 4 NO-TAB-STOP 
     fMonth AT ROW 2.91 COL 9 COLON-ALIGNED WIDGET-ID 16
     fYear AT ROW 2.91 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     fState AT ROW 4.1 COL 9 COLON-ALIGNED WIDGET-ID 42
     brwData AT ROW 6.95 COL 2 WIDGET-ID 200
     tOwnerOnly AT ROW 1.95 COL 121 COLON-ALIGNED WIDGET-ID 24 NO-TAB-STOP 
     tSubjectToReserve AT ROW 1.95 COL 167 COLON-ALIGNED WIDGET-ID 44 NO-TAB-STOP 
     tAgents AT ROW 1.95 COL 86 COLON-ALIGNED WIDGET-ID 22 NO-TAB-STOP 
     tOpenClosed AT ROW 2.91 COL 38 COLON-ALIGNED NO-LABEL WIDGET-ID 50 NO-TAB-STOP 
     tLenderOnly AT ROW 3.14 COL 121 COLON-ALIGNED WIDGET-ID 26 NO-TAB-STOP 
     tBatches AT ROW 3.14 COL 86 COLON-ALIGNED WIDGET-ID 20 NO-TAB-STOP 
     tOwnerLender AT ROW 4.33 COL 121 COLON-ALIGNED WIDGET-ID 38 NO-TAB-STOP 
     tFiles AT ROW 4.33 COL 86 COLON-ALIGNED WIDGET-ID 34 NO-TAB-STOP 
     tLenderOwner AT ROW 5.52 COL 121 COLON-ALIGNED WIDGET-ID 40 NO-TAB-STOP 
     tPolicies AT ROW 5.52 COL 86 COLON-ALIGNED WIDGET-ID 36 NO-TAB-STOP 
     tGrossRate AT ROW 3.14 COL 167 COLON-ALIGNED WIDGET-ID 58 NO-TAB-STOP 
     tNetRate AT ROW 4.33 COL 167 COLON-ALIGNED WIDGET-ID 60 NO-TAB-STOP 
     "Parameters" VIEW-AS TEXT
          SIZE 11 BY .62 AT ROW 1.14 COL 3 WIDGET-ID 56
     "/ $1,000" VIEW-AS TEXT
          SIZE 10 BY .62 AT ROW 3.33 COL 196.6 WIDGET-ID 62
     "/ $1,000" VIEW-AS TEXT
          SIZE 10 BY .62 AT ROW 4.52 COL 196.6 WIDGET-ID 64
     RECT-36 AT ROW 1.48 COL 2 WIDGET-ID 54
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 208 BY 20.76 WIDGET-ID 100.


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
         TITLE              = "Statutory Liability"
         HEIGHT             = 20.76
         WIDTH              = 208
         MAX-HEIGHT         = 25.57
         MAX-WIDTH          = 212.8
         VIRTUAL-HEIGHT     = 25.57
         VIRTUAL-WIDTH      = 212.8
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = yes
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fMain
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB brwData fState fMain */
ASSIGN 
       FRAME fMain:RESIZABLE        = TRUE.

/* SETTINGS FOR BUTTON bExport IN FRAME fMain
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bPrint IN FRAME fMain
   NO-ENABLE                                                            */
ASSIGN 
       brwData:COLUMN-RESIZABLE IN FRAME fMain       = TRUE
       brwData:COLUMN-MOVABLE IN FRAME fMain         = TRUE.

/* SETTINGS FOR RECTANGLE RECT-36 IN FRAME fMain
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tAgents IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tAgents:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tBatches IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tBatches:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tFiles IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tFiles:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tGrossRate IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tGrossRate:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tLenderOnly IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tLenderOnly:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tLenderOwner IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tLenderOwner:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tNetRate IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tNetRate:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tOpenClosed IN FRAME fMain
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN tOwnerLender IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tOwnerLender:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tOwnerOnly IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tOwnerOnly:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tPolicies IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tPolicies:READ-ONLY IN FRAME fMain        = TRUE.

/* SETTINGS FOR FILL-IN tSubjectToReserve IN FRAME fMain
   NO-DISPLAY                                                           */
ASSIGN 
       tSubjectToReserve:READ-ONLY IN FRAME fMain        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE brwData
/* Query rebuild information for BROWSE brwData
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttData.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE brwData */
&ANALYZE-RESUME

 


/* **********************  Create OCX Containers  ********************** */

&ANALYZE-SUSPEND _CREATE-DYNAMIC

&IF "{&OPSYS}" = "WIN32":U AND "{&WINDOW-SYSTEM}" NE "TTY":U &THEN

CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME fMain:HANDLE
       ROW             = 4.67
       COLUMN          = 52
       HEIGHT          = .48
       WIDTH           = 22
       TAB-STOP        = no
       WIDGET-ID       = 52
       HIDDEN          = no
       SENSITIVE       = no.
/* CtrlFrame OCXINFO:CREATE-CONTROL from: {35053A22-8589-11D1-B16A-00C0F0283628} type: ProgressBar */

&ENDIF

&ANALYZE-RESUME /* End of _CREATE-DYNAMIC */


/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Statutory Liability */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Statutory Liability */
DO:
  if tGettingData 
   then return no-apply.

  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Statutory Liability */
DO:
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


&Scoped-define SELF-NAME bPrint
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bPrint C-Win
ON CHOOSE OF bPrint IN FRAME fMain /* Print */
DO:
  run printData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bRefresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bRefresh C-Win
ON CHOOSE OF bRefresh IN FRAME fMain /* Go */
DO:
  setReportButtons("Disable").
  run getData in this-procedure.
  setReportButtons("Enable").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME brwData
&Scoped-define SELF-NAME brwData
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwData C-Win
ON ROW-DISPLAY OF brwData IN FRAME fMain
DO:
  {lib/brw-rowDisplay.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL brwData C-Win
ON START-SEARCH OF brwData IN FRAME fMain
DO:
  {lib/brw-startSearch.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fMonth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fMonth C-Win
ON VALUE-CHANGED OF fMonth IN FRAME fMain /* Period */
DO:
  clearData().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fState
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fState C-Win
ON VALUE-CHANGED OF fState IN FRAME fMain /* State */
DO:
  clearData().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fYear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fYear C-Win
ON VALUE-CHANGED OF fYear IN FRAME fMain
DO:
  clearData().
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

{lib/win-main.i}
{lib/brw-main.i}

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

bRefresh:load-image("images/completed.bmp").
bRefresh:load-image-insensitive("images/completed-i.bmp").
bPrint:load-image("images/pdf.bmp").
bPrint:load-image-insensitive("images/pdf-i.bmp").
bExport:load-image("images/excel.bmp").
bExport:load-image-insensitive("images/excel-i.bmp").

subscribe to "DataError" anywhere.

/* run getData in this-procedure. */

session:immediate-display = yes.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.

  /* create the combos */
  {lib/get-period-list.i &mth=fMonth &yr=fYear}
  {lib/get-state-list.i &combo=fState &addAll=true}
  /* set the values */
  {lib/set-current-value.i &mth=fMonth &yr=fYear &state=fState}
  
  /* get the column width */
  {lib/get-column-width.i &col="'name'" &var=dColumnWidth}
  
  clearData().
  run windowResized.
  
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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

OCXFile = SEARCH( "statliab.wrx":U ).
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
ELSE MESSAGE "statliab.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".

&ENDIF

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DataError C-Win 
PROCEDURE DataError :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  def input param pMsg as char.

  /* Since Progress is single-threaded, this works */
  if not tGettingData 
   then return.

  tKeepGettingData = false.

  message
    pMsg skip(1)
    "Please close and re-run the report or notify" skip
    "the systems administrator if the problem persists."
    view-as alert-box error.

  clearData().
  
  setReportButtons("Enable").

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
  DISPLAY fMonth fYear fState 
      WITH FRAME fMain IN WINDOW C-Win.
  ENABLE bRefresh fMonth fYear fState brwData tOwnerOnly tSubjectToReserve 
         tAgents tLenderOnly tBatches tOwnerLender tFiles tLenderOwner 
         tPolicies tGrossRate tNetRate 
      WITH FRAME fMain IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fMain}
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
  if query brwData:num-results = 0 
   then
    do: 
     MESSAGE "There is nothing to export"
      VIEW-AS ALERT-BOX warning BUTTONS OK.
     return.
    end.

  &scoped-define ReportName "statutory_liability"

  std-ch = "C".
  publish "GetExportType" (output std-ch).
  if std-ch = "X" 
   then run util/exporttoexcelbrowse.p (string(browse {&browse-name}:handle), {&ReportName}).
   else run util/exporttocsvbrowse.p (string(browse {&browse-name}:handle), {&ReportName}).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE filterData C-Win 
PROCEDURE filterData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
def var tTotalGross as decimal no-undo.
def var tTotalNet as decimal no-undo.
def var tTotalLiab as decimal no-undo.

def buffer statliab for statliab.
def buffer ttData for ttData.
  
empty temp-table ttData no-error.

hide message no-pause.
message "Filtering data...".

do with frame {&frame-name}:

  assign
    tAgents = 0
    tBatches = 0
    tFiles = 0
    tPolicies = 0
    tOwnerOnly = 0
    tLenderOnly = 0
    tOwnerLender = 0
    tLenderOwner = 0
    tSubjectToReserve = 0
    tGrossRate = 0.00
    tNetRate = 0.00
    .
    
  for each statliab no-lock
  break by statliab.agentID
        by statliab.batchID 
        by statliab.fileNumber:
   
    process events.
    
    create ttData.
    buffer-copy statliab to ttData.
    
    if first-of(statliab.agentID) then
    tAgents = tAgents + 1.
    
    if first-of(statliab.batchID) then
    tBatches = tBatches + 1.
    
    tFiles = tFiles + 1.
    
    tPolicies = tPolicies + statliab.ownerNum + statliab.lenderNum.
    
    if ttData.lenderLiability > 0 and ttData.ownerLiability = 0 
    then assign
         tLenderOnly = tLenderOnly + ttData.reservableLiability.
    else
    if ttData.lenderLiability = 0 and ttData.ownerLiability > 0 
    then assign
         tOwnerOnly = tOwnerOnly + ttData.reservableLiability.
    else
    if ttData.lenderLiability > ttData.ownerLiability 
    then assign
         tLenderOwner = tLenderOwner + ttData.reservableLiability.
    else
    if ttData.lenderLiability < ttData.ownerLiability 
    then assign
         tOwnerLender = tOwnerLender + ttData.reservableLiability.
    
    tSubjectToReserve = tSubjectToReserve + ttData.reservableLiability.
    tTotalGross = tTotalGross + ttData.grossPremium.
    tTotalNet = tTotalNet + ttData.netPremium.
    tTotalLiab = tTotalLiab + ttData.reservableLiability.
  end.
  
  assign
    tOwnerOnly = round(tOwnerOnly,0)
    tLenderOnly = round(tLenderOnly,0)
    tOwnerLender = round(tOwnerLender,0)
    tLenderOwner = round(tLenderOwner,0)
    tSubjectToReserve = round(tSubjectToReserve,0)
    tGrossRate = tTotalGross / (tTotalLiab / 1000)
    tNetRate = tTotalNet / (tTotalLiab / 1000)
    .
end.

displayTotals().

dataSortBy = "".
run sortData ("agentID").

hide message no-pause.

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
 def buffer statliab for statliab.
 def buffer ttData for ttData.

 def var tSuccess as logical init false no-undo.
 def var tMsg as char no-undo.

 close query brwData.
 empty temp-table statliab.
 empty temp-table ttData.
 clearData().

 tNumTasks = 2.
 tCurTask = 1.
 pbMinStatus().

 tGettingData = true.
 tkeepGettingData = true.

 hide message no-pause.
 message "Getting data...".

 GETTING-DATA:
 do with frame {&frame-name}:
   pbUpdateStatus(tCurTask, 0).
   
   find period
     where period.periodMonth = fMonth:input-value
       and period.periodYear = fYear:input-value no-error.
   if not available period
    then return.
    
   run server/getstatliab.p (input period.periodID,
                             input fState:input-value in frame {&frame-name},
                             output table statliab,
                             output tSuccess,
                             output tMsg).
    if not tSuccess
     then 
      do: std-lo = false.
          publish "GetAppDebug" (output std-lo).
          if std-lo 
           then message "GetStatLiab failed: " tMsg view-as alert-box warning.
      end.
  
   process events.
      
   if not tKeepGettingData 
    then leave GETTING-DATA.
   
   pbUpdateStatus(int((tCurTask / tNumTasks) * 100), 0).
 end. /* GETTING-DATA */
 
 if not tKeepGettingData 
  then
   do:
       close query brwData.
       empty temp-table statliab.
       empty temp-table ttData.
       clearData().

       hide message no-pause.
       message "Cancelled (" + string(now,"99/99/99 HH:MM:SS") + ")".
       pbUpdateStatus(100, 1).
       pbMinStatus().
       tGettingData = false.
       return.
   end.
 
 for each statliab exclusive-lock:
  assign
    statliab.grossRate = statliab.grossPremium / (statliab.reservableLiability / 1000)
    statliab.grossRate = (if statliab.grossRate = ? then 0 else statliab.grossRate)
    statliab.netRate = statliab.netPremium / (statliab.reservableLiability / 1000)
    statliab.netRate = (if statliab.netRate = ? then 0 else statliab.netRate)
    .
 end.
 run filterData.

 pbUpdateStatus(100, 1).
 pbMinStatus().
 tGettingData = false. 
 hide message no-pause.
 message "Report Complete for Period " + 
         fMonth:screen-value in frame fMain + "/" +
         fYear:screen-value in frame fMain + "  " +
         "(" + string(now,"99/99/99 HH:MM:SS") + ")".
 message.
 
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE printData C-Win 
PROCEDURE printData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 if query brwData:num-results = 0 /* or not available batch */
  then
   do: 
    MESSAGE "There is nothing to print"
     VIEW-AS ALERT-BOX warning BUTTONS OK.
    return.
   end.

 do with frame {&frame-name}:
   run rpt/statliab-pdf.p (input fMonth:input-value,
                           input fYear:input-value,
                           input fState:input-value,
                           input tAgents:input-value,
                           input tBatches:input-value,
                           input tFiles:input-value,
                           input tPolicies:input-value,
                           input tOwnerOnly:input-value,
                           input tLenderOnly:input-value,
                           input tOwnerLender:input-value,
                           input tLenderOwner:input-value,
                           input tSubjectToReserve:input-value,
                           input table ttData).
 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SetDataSource C-Win 
PROCEDURE SetDataSource :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 def input parameter p as handle.

 if valid-handle(p) 
  then hData = p.
 run getData in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ShowWindow C-Win 
PROCEDURE ShowWindow :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 {&window-name}:move-to-top().
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

{lib/brw-sortData.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE windowResized C-Win 
PROCEDURE windowResized PRIVATE :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 frame {&frame-name}:width-pixels = {&window-name}:width-pixels.
 frame {&frame-name}:virtual-width-pixels = {&window-name}:width-pixels.
 frame {&frame-name}:height-pixels = {&window-name}:height-pixels.
 frame {&frame-name}:virtual-height-pixels = {&window-name}:height-pixels.

 /* {&frame-name} components */
 {&browse-name}:width-pixels = frame {&frame-name}:width-pixels - 10.
 {&browse-name}:height-pixels = frame {&frame-name}:height-pixels - {&browse-name}:y - 5.
 
 {lib/resize-column.i &col="'name'" &var=dColumnWidth}
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
  do with frame {&frame-name}:
    close query brwData.
    hide message no-pause.
    clear frame fMain.
    
    assign
      tAgents = 0
      tBatches = 0
      tFiles = 0
      tPolicies = 0
      tOwnerOnly = 0
      tLenderOnly = 0
      tOwnerLender = 0
      tLenderOwner = 0
      tSubjectToReserve = 0
      .
      
    fState:screen-value = "".
    
    find first period where period.periodMonth = fMonth:input-value
                        and period.periodYear = fYear:input-value
                        no-lock no-error.
    tOpenClosed = if avail period 
                  then if period.active then "(Open)" else "(Closed)"
                  else "".
    display tOpenClosed.
  end.
                  
  RETURN true.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION displayTotals C-Win 
FUNCTION displayTotals RETURNS LOGICAL PRIVATE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
 
do with frame {&frame-name}:
  assign
    tOwnerOnly        = round(tOwnerOnly,0)       
    tLenderOnly       = round(tLenderOnly,0)      
    tOwnerLender      = round(tOwnerLender,0)     
    tLenderOwner      = round(tLenderOwner,0)     
    tSubjectToReserve = round(tSubjectToReserve,0).
  
  display
    tAgents
    tBatches
    tFiles
    tPolicies
    tOwnerOnly
    tLenderOnly
    tOwnerLender
    tLenderOwner
    tSubjectToReserve
    tGrossRate
    tNetRate.
  
  pause 0.
end.

RETURN true.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION pbMinStatus C-Win 
FUNCTION pbMinStatus RETURNS LOGICAL
  ( /* parameter-definitions */ ) :

  chCtrlFrame:ProgressBar:VALUE = chCtrlFrame:ProgressBar:MIN.
  
  RETURN true.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION pbUpdateStatus C-Win 
FUNCTION pbUpdateStatus RETURNS LOGICAL
  ( input pPercentage   as int,
    input pPauseSeconds as int ) :

  {&WINDOW-NAME}:move-to-top().
  
  do with frame {&frame-name}:
    if chCtrlFrame:ProgressBar:VALUE <> pPercentage then
    assign
      chCtrlFrame:ProgressBar:VALUE = pPercentage.
      
    if pPauseSeconds > 0 then
    pause pPauseSeconds no-message.
  end.

  RETURN true.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setReportButtons C-Win 
FUNCTION setReportButtons RETURNS LOGICAL
  ( input pCmd as char ) :

  do with frame {&frame-name}:
    case pCmd:
      when "Enable" then
      assign
        bRefresh:sensitive = yes
        bPrint:sensitive   = yes
        bExport:sensitive  = yes.
      when "Disable" then
      assign
        bRefresh:sensitive = no
        bPrint:sensitive   = no
        bExport:sensitive  = no.
      otherwise
        .
    end case.
  end.

  RETURN true.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

