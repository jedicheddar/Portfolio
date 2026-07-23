&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter pAgentID as character no-undo.

/* Temp Tables ---                                                      */
{tt/agent.i}
{tt/state.i}
{tt/alert.i &tableAlias="data"}
{tt/alert.i &tableAlias="tempdata"}

/* Local Variable Definitions ---                                       */
define variable dMaxWindowHeight as decimal no-undo.
define variable dMinWindowWidth as decimal no-undo.
define variable dMinWindowHeight as decimal no-undo.
define variable dMinCodeWidth as decimal no-undo.
define variable dMinCodeHeight as decimal no-undo.
/* where to put the results */
define variable dAlertStartRow as decimal no-undo.
/* capture the alerts */
define variable cCheckedAlerts as character no-undo.
{lib/std-def.i}
{lib/add-delimiter.i}
{lib/find-widget.i}
{lib/getstatename.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fAlert

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rCodes bRefresh tStateID tAgentID 
&Scoped-Define DISPLAYED-OBJECTS tStateID tAgentID 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD clearData C-Win 
FUNCTION clearData RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getAlertFrame C-Win 
FUNCTION getAlertFrame RETURNS HANDLE
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getAlertList C-Win 
FUNCTION getAlertList RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getCheckedAlerts C-Win 
FUNCTION getCheckedAlerts RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setCheckedAlerts C-Win 
FUNCTION setCheckedAlerts RETURNS LOGICAL
  ( input pAlerts as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bRefresh 
     LABEL "Go" 
     SIZE 4.8 BY 1.14.

DEFINE VARIABLE tAgentID AS CHARACTER FORMAT "X(256)":U 
     LABEL "Agent" 
     VIEW-AS FILL-IN 
     SIZE 122 BY 1 NO-UNDO.

DEFINE VARIABLE tStateID AS CHARACTER FORMAT "X(256)":U 
     LABEL "State" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.

DEFINE RECTANGLE rCodes
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 163 BY 2.14.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fAlert
     bRefresh AT ROW 1.38 COL 160.2 WIDGET-ID 92
     tStateID AT ROW 1.48 COL 6 COLON-ALIGNED WIDGET-ID 96
     tAgentID AT ROW 1.48 COL 35 COLON-ALIGNED WIDGET-ID 94
     "Codes" VIEW-AS TEXT
          SIZE 6.2 BY .62 AT ROW 2.67 COL 3 WIDGET-ID 90
     rCodes AT ROW 2.91 COL 2 WIDGET-ID 86
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 165 BY 4.24 WIDGET-ID 100.


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
         TITLE              = "Preview Alerts"
         HEIGHT             = 4.24
         WIDTH              = 165
         MAX-HEIGHT         = 48.43
         MAX-WIDTH          = 384
         VIRTUAL-HEIGHT     = 48.43
         VIRTUAL-WIDTH      = 384
         MIN-BUTTON         = no
         RESIZE             = no
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         FONT               = 18
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME fAlert
   FRAME-NAME                                                           */
ASSIGN 
       tAgentID:READ-ONLY IN FRAME fAlert        = TRUE.

ASSIGN 
       tStateID:READ-ONLY IN FRAME fAlert        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Preview Alerts */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Preview Alerts */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Preview Alerts */
DO:
  run windowResized in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bRefresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bRefresh C-Win
ON CHOOSE OF bRefresh IN FRAME fAlert /* Go */
DO:
  clearData().
  run getData in this-procedure (true).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

{lib/win-main.i}
{lib/win-close.i}
{lib/win-show.i}
{winfunc.i}

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

bRefresh:load-image("images/s-completed.bmp").
bRefresh:load-image-insensitive("images/s-completed-i.bmp").

publish "GetAgent" (pAgentID, output table agent).
assign
  dMaxWindowHeight = session:height-chars
  dMinWindowWidth = {&window-name}:width-chars
  dMinWindowHeight = {&window-name}:height-chars
  dMinCodeWidth = rCodes:width-pixels
  dMinCodeHeight = rCodes:height-chars
  .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  /* set the title */
  for first agent no-lock:
    {&window-name}:title = "Evaluate Current Alerts for " + agent.name.
    tAgentID:screen-value = agent.name + " (" + agent.agentID + ")".
    tStateID:screen-value = getStateName(agent.stateID).
  end.
  
  run windowResized in this-procedure.
  clearData().
  
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addAlerts C-Win 
PROCEDURE addAlerts :
/*------------------------------------------------------------------------------
@description Adds the alerts to the screen
------------------------------------------------------------------------------*/
  define variable hWidget as handle no-undo.
  define variable iRow as integer no-undo initial 1.
  define variable iCol as integer no-undo initial 1.
  define variable iData as integer no-undo initial 0.
  /* the column and row of where the alert start */
  define variable dRow as decimal no-undo initial 1.5.
  define variable dCol as decimal no-undo initial 2.
  /* the width and height of the frame */
  define variable hFrame as handle no-undo.
  define variable dMaxHeight as decimal no-undo.
  define variable dAlertHeight as decimal no-undo initial 4.
  define variable dAlertWidth as decimal no-undo initial 80.
  define variable dMaxText as integer no-undo initial 5.
  define variable dMaxRow as integer no-undo initial 3.
  /* the number of columns to display */
  define variable iNumCol as integer no-undo.
  /* fields for alerts */
  define buffer data for data.
  define variable cEffectiveDate as character no-undo.
  define variable cThreshold as character no-undo.
  define variable cScore as character no-undo.
  define variable cNote as character no-undo.
  define variable cOwner as character no-undo.
  define variable iSeverity as integer no-undo.
  
  assign
    iNumCol = truncate(({&window-name}:width-chars - (dCol * 2)) / dAlertWidth, 0)
    dAlertWidth = truncate(({&window-name}:width-chars - dCol - 10) / iNumCol, 2)
    dMaxText = truncate(dAlertWidth, 0) - dMaxText
    dMaxHeight = dAlertStartRow + (dAlertHeight * dMaxRow)
    .
  /* create a new frame if alerts are available */
  hFrame = getAlertFrame().
  if can-find(first data) and not valid-handle(hFrame)
   then 
    do:
      if {&window-name}:window-state = 3 and {&window-name}:height-chars < dAlertStartRow + 2
       then
        assign
          {&window-name}:height-chars = dAlertStartRow
          frame {&frame-name}:height-chars = {&window-name}:height-chars
          frame {&frame-name}:virtual-height-chars = {&window-name}:height-chars + dAlertHeight
          .
      /* create the frame */
      create frame hFrame in widget-pool "alerts" assign
        row = dAlertStartRow + 0.2
        column = 1
        width-chars = {&window-name}:width-chars
        height-chars = dAlertHeight
        name = "fPreview"
        three-d = true
        box = false
        sensitive = true
        visible = false
        .
    end.
    
  /* count the number of data entries */
  iData = 0.
  for each data no-lock:
    iData = iData + 1.
  end.
  
  /* begin loop of alerts */
  std-in = 0.
  for each data no-lock:
    assign
      std-in = std-in + 1
      cEffectiveDate = string(data.effDate, "99/99/9999")
      cThreshold = data.thresholdRange
      cScore = data.scoreDesc
      cNote = data.note
      iSeverity = data.severity
      .
    publish "GetSysPropDesc" ("AMD", "Alert", "Owner", data.owner, output cOwner).
    /* create the alert */
    /* image */
    create image hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + 0.7 + (dAlertHeight * (iRow - 1))
      column = dCol + 1 + (dAlertWidth * (iCol - 1))
      width-chars = 7.2
      height-chars = 1.71
      sensitive = false
      visible = true
      tooltip = cNote
      .
    case iSeverity:
     when 0 then std-ch = "images/smiley-sqare-green-32.gif".
     when 1 then std-ch = "images/smiley-sqare-yellow-32.gif".
     when 2 then std-ch = "images/smiley-sqare-red-32.gif".
    end case.
    hWidget:load-image(std-ch).
    /* label */
    std-ch = "".
    publish "GetSysCodeDesc" ("Alert", data.processCode, output std-ch).
    create text hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + (dAlertHeight * (iRow - 1))
      column = dCol + 10 + (dAlertWidth * (iCol - 1)) 
      width-chars = dAlertWidth - 10
      height-chars = 1
      format = "x(50)"
      screen-value = std-ch
      tooltip = cNote
      sensitive = true
      visible = true
      font = 5
      .
    /* if the text is too long, put the rest in the tooltip */
    if length(std-ch) > dMaxText
     then
      assign
        hWidget:screen-value = substring(std-ch, 1,  r-index(std-ch, " ", dMaxText) - 1) + "..."
        hWidget:tooltip = "..." + substring(std-ch, r-index(std-ch, " ", dMaxText) + 1, length(std-ch) - 3)
        .
    /* Effective Date */
    create text hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + 1 + (dAlertHeight * (iRow - 1))
      column = dCol + 12 + (dAlertWidth * (iCol - 1)) 
      width-chars = 38
      height-chars = 1
      format = "x(50)"
      screen-value = "Effective Date: " + cEffectiveDate
      tooltip = cNote
      sensitive = true
      visible = true
      .
    /* Threshold */
    create text hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + 2 + (dAlertHeight * (iRow - 1))
      column = dCol + 16.2 + (dAlertWidth * (iCol - 1)) 
      width-chars = 38
      height-chars = 1
      format = "x(50)"
      screen-value = "Threshold: " + cThreshold
      tooltip = cNote
      sensitive = true
      visible = true
      .
    /* Owner */
    create text hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + 1 + (dAlertHeight * (iRow - 1))
      column = dCol + 49 + (dAlertWidth * (iCol - 1)) 
      width-chars = 28
      height-chars = 1
      format = "x(50)"
      screen-value = "Owner: " + cOwner
      tooltip = cNote
      sensitive = true
      visible = true
      .
    /* Score */
    create text hWidget in widget-pool "alerts" assign
      frame = hFrame
      row = dRow + 2 + (dAlertHeight * (iRow - 1))
      column = dCol + 47 + (dAlertWidth * (iCol - 1)) 
      width-chars = 28
      height-chars = 1
      format = "x(50)"
      screen-value = "Measure: " + cScore
      tooltip = cNote
      sensitive = true
      visible = true
      .
    /* at the end of the row */
    if std-in modulo iNumCol = 0
     then 
      assign
        iCol = 1
        iRow = iRow + 1
        hFrame:virtual-height-chars =  dAlertHeight * iRow
        .
     else iCol = iCol + 1.
  end. /* for each data */
  /* add the row number for adding the last row if didn't already */
  if std-in modulo iNumCol <> 0
   then iRow = iRow + 1.
  std-de = dAlertHeight * (iRow - 1).
  hFrame:virtual-height-chars =  std-de.
  if {&window-name}:window-state = 1 /* 1 = maximized*/
   then hFrame:height-chars = frame {&frame-name}:height-chars - 9.
   else
    do:
      assign
        {&window-name}:height-chars = dAlertStartRow + std-de
        frame {&frame-name}:height-chars = {&window-name}:height-chars
        frame {&frame-name}:virtual-height-chars = {&window-name}:height-chars
        hFrame:height-chars = frame {&frame-name}:height-chars - dAlertStartRow
        .
      if {&window-name}:height-chars > dMaxHeight + 0.3
       then
        assign
          {&window-name}:height-chars = dMaxHeight + 0.3
          frame {&frame-name}:height-chars = {&window-name}:height-chars
          frame {&frame-name}:virtual-height-chars = {&window-name}:height-chars
          hFrame:height-chars = frame {&frame-name}:height-chars - dAlertStartRow - 0.3
          .
    end.
  /* create the run alert button */
  /* if uncommenting, make 0.3 from above to 2 */
  /*create button hWidget in widget-pool "alerts" assign
    frame = frame {&frame-name}:handle
    row = frame {&frame-name}:height-chars - 0.5
    column = ({&window-name}:width-chars - 15) / 2
    width-chars = 15
    height-chars = 1
    label = "Create Alerts"
    sensitive = true
    visible = true
    triggers:
      on "CHOOSE" persistent run getData in this-procedure (false).
    end triggers.
    .*/
  run util/RemoveHScrollbar.p (hFrame).
  frame {&frame-name}:visible = true.
  hFrame:visible = true.
  frame {&frame-name}:move-to-top().
  hFrame:move-to-top().
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addCodes C-Win 
PROCEDURE addCodes :
/*------------------------------------------------------------------------------
@description Adds the checkboxes to the page
------------------------------------------------------------------------------*/
  define variable hWidget as handle no-undo.
  define variable iRow as integer no-undo initial 1.
  define variable iCol as integer no-undo initial 1.
  define variable cLabel as character no-undo.
  define variable cTooltip as character no-undo.
  /* the column and row of where the checkboxes start */
  define variable dCol as decimal no-undo initial 4.
  define variable dRow as decimal no-undo initial 3.62.
  /* the width and height */
  define variable dWidth as decimal no-undo initial 35.
  define variable dHeight as decimal no-undo initial 1.
  define variable dMaxText as integer no-undo initial 5.
  /* the number of columns to display */
  define variable iNumCol as integer no-undo initial 3.
  
  assign
    iNumCol = truncate((rCodes:width-chars in frame {&frame-name} - 3) / dWidth, 0)
    dWidth = truncate((rCodes:width-chars in frame {&frame-name} - 3) / iNumCol, 2)
    dMaxText = truncate(dWidth,0) - dMaxText
    .
  
  std-ch = getAlertList().
  std-ch = addDelimiter(std-ch, ",") + "ALL,ALL".
  /* Place the checkboxes */
  do std-in = 1 to num-entries(std-ch) / 2:
    assign
      cLabel = entry(std-in * 2 - 1, std-ch)
      cTooltip = ""
      std-lo = false
      .
    create toggle-box hWidget in widget-pool "codes" assign
      frame = frame {&frame-name}:handle
      row = dRow + (dHeight * (iRow - 1))
      column = dCol + (dWidth * (iCol - 1))
      width-chars = dWidth
      height-chars = dHeight
      sensitive = true
      visible = true
      label = cLabel
      tooltip = cTooltip
      name = entry(std-in * 2, std-ch)
      triggers:
        on "VALUE-CHANGED" persistent run selectCodes in this-procedure (entry(std-in * 2, std-ch) = "ALL").
      end triggers.
      .
    /* if the text is too long, put the rest in the tooltip */
    if length(cLabel) > dMaxText
     then
      assign
        hWidget:label = substring(cLabel, 1,  r-index(cLabel, " ", dMaxText) - 1) + "..."
        hWidget:tooltip = "..." + substring(cLabel, r-index(cLabel, " ", dMaxText) + 1, length(cLabel) - 3)
        .
    /* at the end of the row */
    if std-in modulo iNumCol = 0
     then 
      do:
        iCol = 1.
        iRow = iRow + 1.
        /* create more height for the window */
        if std-in modulo (num-entries(std-ch) / 2) <> 0
         then
          do:
            /* does the window need to be resized? */
            std-de = (dHeight * (iRow - 1)).
            if {&window-name}:height-chars < dMinWindowHeight + std-de
             then
              assign
                {&window-name}:height-chars = dMinWindowHeight + std-de
                frame {&frame-name}:height-chars = {&window-name}:height-chars
                frame {&frame-name}:virtual-height-chars = {&window-name}:height-chars
                .
            rCodes:height-chars = dMinCodeHeight + std-de.
          end.
      end.
     else iCol = iCol + 1.
  end.
  /* add the row number for adding the last row if didn't already */
  if (std-in - 1) modulo iNumCol <> 0
   then iRow = iRow + 1.
  /* capture the starting row of the alerts */
  dAlertStartRow = dMinWindowHeight + (dHeight * (iRow - 1)).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE addLegend C-Win 
PROCEDURE addLegend :
/*------------------------------------------------------------------------------
@description Adds the legend to the screen
------------------------------------------------------------------------------*/
  define variable hWidget as handle no-undo.
  define variable dOffset as decimal no-undo initial 0.
  dOffset = ({&window-name}:width-chars - 60) / 2.
  
  /* create the legend */
  create image hWidget in widget-pool "alerts" assign
    frame = frame {&frame-name}:handle
    row = dAlertStartRow + 0.1
    column = 1 + dOffset
    width-chars = 4.8
    height-chars = 1.14
    sensitive = false
    visible = true
    .
  hWidget:load-image("images/smiley-sqare-green-18.gif").
  create image hWidget in widget-pool "alerts" assign
    frame = frame {&frame-name}:handle
    row = dAlertStartRow + 0.1
    column = 27 + dOffset
    width-chars = 4.8
    height-chars = 1.14
    sensitive = false
    visible = true
    .
  hWidget:load-image("images/smiley-sqare-yellow-18.gif").
  create image hWidget in widget-pool "alerts" assign
    frame = frame {&frame-name}:handle
    row = dAlertStartRow + 0.1
    column = 53 + dOffset
    width-chars = 4.8
    height-chars = 1.14
    sensitive = false
    visible = true
    .
  hWidget:load-image("images/smiley-sqare-red-18.gif").
  
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
  DISPLAY tStateID tAgentID 
      WITH FRAME fAlert IN WINDOW C-Win.
  ENABLE rCodes bRefresh tStateID tAgentID 
      WITH FRAME fAlert IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fAlert}
  VIEW C-Win.
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
  define input parameter pPreview as logical no-undo.
  define buffer tempdata for tempdata.
  
  if pPreview
   then
    do:
      cCheckedAlerts = getCheckedAlerts().
      
      if cCheckedAlerts = ""
       then
        do:
          message "There are no codes selected. Do you want to run the report for all codes?" view-as alert-box information buttons yes-no update std-lo.
          if not std-lo
           then return.
          
          std-ch = getAlertList().
          setCheckedAlerts(addDelimiter(std-ch, ",") + "ALL,ALL").
        end.
      
      if index(cCheckedAlerts, "ALL") > 0
       then cCheckedAlerts = "ALL".
       
      empty temp-table data.
    end.
  
  empty temp-table tempdata.
  DisableNotResponding().
  run server/runagentalerts.p (input cCheckedAlerts,
                               input pAgentID,
                               input pPreview,
                               input 0,
                               input ?,
                               output table tempdata,
                               output std-lo,
                               output std-ch
                               ).
                               
  if not std-lo
   then message std-ch view-as alert-box error buttons ok.
   else
    do:
      if pPreview
       then
        for each tempdata no-lock:
          create data.
          buffer-copy tempdata to data.
        end.
        
      if can-find(first data)
       then run addAlerts in this-procedure.
    end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE selectCodes C-Win 
PROCEDURE selectCodes :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pAllSelected as logical no-undo.
  
  define variable lAllCodesSelected as logical no-undo initial true.
  define variable hAllCheckbox as handle no-undo.
  hAllCheckbox = GetWidgetByName(frame {&frame-name}:handle, "ALL").
  if not valid-handle(hAllCheckbox)
   then return.
  
  std-ch = getAlertList().
  do std-in = 1 to num-entries(std-ch) / 2:
    std-ha = GetWidgetByName(frame {&frame-name}:handle, entry(std-in * 2, std-ch)).
    if valid-handle(std-ha) and std-ha:type = "TOGGLE-BOX"
     then
      do:
        lAllCodesSelected = (std-ha:checked and lAllCodesSelected).
        if pAllSelected
         then std-ha:checked = hAllCheckbox:checked.
      end.
  end.
  
  if not pAllSelected
   then hAllCheckbox:checked = lAllCodesSelected.
  
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
  define variable dDiffWidth as decimal no-undo.
  define variable dDiffHeight as decimal no-undo.
  define variable cAlerts as character no-undo.
  
  /* get the check boxes */
  cAlerts = getCheckedAlerts().
  
  /* delete the widget pools */
  delete widget-pool "codes" no-error.
  create widget-pool "codes" persistent.
  delete widget-pool "alerts" no-error.
  create widget-pool "alerts" persistent.
  
  if {&window-name}:width-chars < dMinWindowWidth or {&window-name}:height-chars < dMinWindowHeight
   then
    assign
      {&window-name}:width-chars = dMinWindowWidth
      {&window-name}:height-chars = dMinWindowHeight
      .
  assign
    frame {&frame-name}:width-pixels = {&window-name}:width-pixels
    frame {&frame-name}:virtual-width-pixels = {&window-name}:width-pixels
    frame {&frame-name}:height-pixels = {&window-name}:height-pixels
    frame {&frame-name}:virtual-height-pixels = {&window-name}:height-pixels
    .
  
  /* get the difference between the old and new width\height */
  dDiffWidth = frame {&frame-name}:width-pixels - (dMinWindowWidth * session:pixels-per-column).
  dDiffHeight = frame {&frame-name}:height-pixels - (dMinWindowHeight * session:pixels-per-row).
  
  /* resize the codes window */
  rCodes:width-pixels = dMinCodeWidth + dDiffWidth - 2.
  
  /* remake the code boxes */
  run addCodes in this-procedure.
  setCheckedAlerts(cAlerts).
  
  /* remake the alert */
  if can-find(first data)
   then run addAlerts in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION clearData C-Win 
FUNCTION clearData RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  /* delete the widget pools */
  empty temp-table data.
  delete widget-pool "alerts" no-error.
  create widget-pool "alerts" persistent.
  
  if {&window-name}:window-state = 3 and dAlertStartRow > 0
   then
    assign
      {&window-name}:height-chars = dAlertStartRow - 1
      frame {&frame-name}:virtual-height-chars = {&window-name}:height-chars
      frame {&frame-name}:height-chars = {&window-name}:height-chars
      .
  RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getAlertFrame C-Win 
FUNCTION getAlertFrame RETURNS HANDLE
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable lhScanWidget as widget-handle no-undo.
  define variable lhTmpWidget as widget-handle no-undo.
  define variable llFound as logical no-undo initial false.

  lhScanWidget = {&window-name}:first-child.
  do while valid-handle(lhScanWidget) and (not llFound):
    if lhScanWidget:type = "FRAME"
     then llFound = (lhScanWidget:name = "fPreview").
    
    if not llFound 
     then lhScanWidget = lhScanWidget:next-sibling.
  end.

  return lhScanWidget.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getAlertList C-Win 
FUNCTION getAlertList RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable cOrigList as character no-undo.
  define variable cNewList as character no-undo.
  define variable iItem as integer no-undo.
  define variable lUserDefined as logical no-undo.
  
  publish "GetSysCodeList" ("Alert", output cOrigList).
  /* Get rid of all user defined items */
  do iItem = 1 to num-entries(cOrigList, {&msg-dlm}) / 2:
    lUserDefined = false.
    publish "IsAlertUserDefined" (entry(iItem * 2, cOrigList, {&msg-dlm}), output lUserDefined).
    if not lUserDefined
     then cNewList = addDelimiter(cNewList, ",") + entry(iItem * 2 - 1, cOrigList, {&msg-dlm}) + "," + entry(iItem * 2, cOrigList, {&msg-dlm}).
  end.
  RETURN cNewList.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getCheckedAlerts C-Win 
FUNCTION getCheckedAlerts RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
@desctiption Gets the toggle boxes that are checked
------------------------------------------------------------------------------*/
  define variable hChild as handle no-undo.
  define variable cAlerts as character no-undo initial "".
  
  hChild = frame {&frame-name}:first-child:first-child.
  do while valid-handle(hChild):
    if hChild:type = "TOGGLE-BOX" and hChild:checked
     then cAlerts = addDelimiter(cAlerts, ",") + hChild:name.
     
    hChild = hChild:next-sibling.
  end.
  RETURN cAlerts.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setCheckedAlerts C-Win 
FUNCTION setCheckedAlerts RETURNS LOGICAL
  ( input pAlerts as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable hChild as handle no-undo.
  define variable iAlert as integer no-undo.
     
  do iAlert = 1 to num-entries(pAlerts):
    hChild = GetWidgetByName(frame {&frame-name}:handle, entry(iAlert, pAlerts)).
    if valid-handle(hChild) and hChild:type = "TOGGLE-BOX"
     then hChild:checked = true.
  end.
  RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

