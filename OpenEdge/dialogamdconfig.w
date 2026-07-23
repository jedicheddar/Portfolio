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

/* Local Variable Definitions ---                                       */
define variable cOption as character no-undo.
{lib/std-def.i}

/* Functions ---                                                        */
{lib/dialog-config-def.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fConfig

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rStartup rOptions tDefaultView tDoubleClick ~
tDefaultStatus bSave bCancel 
&Scoped-Define DISPLAYED-OBJECTS tDefaultView tDoubleClick tDefaultStatus 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bCancel AUTO-END-KEY 
     LABEL "Cancel" 
     SIZE 17 BY 1.19
     BGCOLOR 8 .

DEFINE BUTTON bSave AUTO-GO 
     LABEL "Save" 
     SIZE 17 BY 1.19
     BGCOLOR 8 .

DEFINE VARIABLE tDefaultStatus AS CHARACTER FORMAT "X(256)":U 
     LABEL "Default Status" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE tDefaultView AS CHARACTER FORMAT "X(256)":U 
     LABEL "Default View" 
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "ALL","ALL"
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE tDoubleClick AS CHARACTER FORMAT "X(256)":U INITIAL "S" 
     LABEL "Double Click" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Modify Agent","M",
                     "Agent Summary","S"
     DROP-DOWN-LIST
     SIZE 31 BY 1 NO-UNDO.

DEFINE RECTANGLE rOptions
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 100 BY 7.62.

DEFINE RECTANGLE rStartup
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 64 BY 12.86.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fConfig
     tDefaultView AT ROW 9.81 COL 5.8 WIDGET-ID 242
     tDoubleClick AT ROW 11.48 COL 32.8 WIDGET-ID 246
     tDefaultStatus AT ROW 9.81 COL 53.4 WIDGET-ID 244
     bSave AT ROW 14.81 COL 68.4 WIDGET-ID 222
     bCancel AT ROW 14.81 COL 86.4 WIDGET-ID 220
     "Load on Startup" VIEW-AS TEXT
          SIZE 15.6 BY .62 AT ROW 1.24 COL 106 WIDGET-ID 4
     "Options" VIEW-AS TEXT
          SIZE 7.6 BY .62 AT ROW 1.24 COL 4 WIDGET-ID 184
     rStartup AT ROW 1.48 COL 105 WIDGET-ID 2
     rOptions AT ROW 1.48 COL 3 WIDGET-ID 182
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 170 BY 15.48 WIDGET-ID 100.


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
         TITLE              = "Configuration"
         HEIGHT             = 15.48
         WIDTH              = 170
         MAX-HEIGHT         = 24.05
         MAX-WIDTH          = 170.8
         VIRTUAL-HEIGHT     = 24.05
         VIRTUAL-WIDTH      = 170.8
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
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
/* SETTINGS FOR FRAME fConfig
   FRAME-NAME L-To-R,COLUMNS                                            */
/* SETTINGS FOR COMBO-BOX tDefaultStatus IN FRAME fConfig
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX tDefaultView IN FRAME fConfig
   ALIGN-L                                                              */
/* SETTINGS FOR COMBO-BOX tDoubleClick IN FRAME fConfig
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Configuration */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Configuration */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bCancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bCancel C-Win
ON CHOOSE OF bCancel IN FRAME fConfig /* Cancel */
DO:
  apply "WINDOW-CLOSE" to {&WINDOW-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bSave C-Win
ON CHOOSE OF bSave IN FRAME fConfig /* Save */
DO:
  saveConfig().
  publish "SetDoubleClick" (tDoubleClick:screen-value).
  publish "SetDefaultStatus" (tDefaultStatus:input-value).
  publish "SetDefaultView" (tDefaultView:input-value).
  
  apply "WINDOW-CLOSE" to {&window-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

{lib/win-main.i}
{lib/win-close.i}
{lib/win-show.i}

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 before-hide.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  {lib/dialog-config-add-load.i     &label="Agents"                                                                                                                              &mandatory=true}
  {lib/dialog-config-add-load.i     &label="States"                                                                                                                              &mandatory=true}
  {lib/dialog-config-add-load.i     &label="System Codes"        &loadProc="LoadSysCodes"  &modProc="SysCodeDataChanged"  &setProc="SetLoadSysCodes"  &getProc="GetLoadSysCodes" &mandatory=true}
  {lib/dialog-config-add-load.i     &label="System Properties"   &loadProc="LoadSysProps"  &modProc="SysPropDataChanged"  &setProc="SetLoadSysProps"  &getProc="GetLoadSysProps" &mandatory=true}
  {lib/dialog-config-add-load.i     &label="Activities"                                    &modProc="ActivityDataChanged"}
  {lib/dialog-config-add-load.i     &label="Alerts"                                        &modProc="AgentsDataChanged"}
  {lib/dialog-config-add-load.i     &label="Agent Applications"  &loadProc="LoadAgentApps" &modProc="AgentAppDataChanged" &setProc="SetLoadAgentApps" &getProc="GetLoadAgentApps"}
  {lib/dialog-config-add-load.i     &label="Attorneys"}
  {lib/dialog-config-add-load.i     &label="Counties"                                      &modProc="CountyDataChanged"}
  {lib/dialog-config-add-load.i     &label="Periods"}
  {lib/dialog-config-add-load.i     &label="Regions"}
  {lib/dialog-config-add-load.i     &label="Offices"}
  {lib/dialog-config-add-load.i     &label="System Users"        &loadProc="LoadSysUsers"  &modProc="UserDataChanged"     &setProc="SetLoadSysUsers"  &getProc="GetLoadSysUsers"}
  {lib/dialog-config-add-file.i     &label="Temporary Directory"                                                          &setProc="SetTempDir"       &getProc="GetTempDir"}
  {lib/dialog-config-add-file.i     &label="Report Directory"                                                             &setProc="SetReportDir"     &getProc="GetReportDir"}
  {lib/dialog-config-add-checkbox.i &label="Confirm Close"}
  {lib/dialog-config-add-checkbox.i &label="Confirm File Upload"}
  {lib/dialog-config-add-checkbox.i &label="Confirm Status Change"}
  {lib/dialog-config-add-checkbox.i &label="Confirm Delete"}
  {lib/dialog-config-add-checkbox.i &label="Confirm Exit"}
  {lib/dialog-config-add-checkbox.i &label="Auto-View Data"                                                               &setProc="SetAutoView"      &getProc="GetAutoView"}
  {lib/dialog-config-add-checkbox.i &label="Refresh Data Immediately"                                                     &setProc="SetRefresh"       &getProc="GetRefresh"}
  {lib/dialog-config-add-radio.i    &label="Notes View"           &options="Page,P,Browse,B"                              &setProc="SetNoteWindow"    &getProc="GetNoteWindow"}
  setConfig(frame {&frame-name}:handle, rStartup:handle, rOptions:handle).

  /* default view */
  tDefaultView:delimiter = {&msg-dlm}.
  cOption = "".
  publish "GetDefaultView" (output cOption).
  {lib/get-sysprop-list.i &combo=tDefaultView &appCode="'AMD'" &objAction="'Main'" &objProperty="'View'" &d=cOption}
  
  /* default status */
  tDefaultStatus:delimiter = {&msg-dlm}.
  cOption = "".
  publish "GetDefaultStatus" (output cOption).
  {lib/get-sysprop-list.i &combo=tDefaultStatus &appCode="'AMD'" &objAction="'Agent'" &objProperty="'Status'" &addAll=true &d=cOption}
  
  /* double click */
  std-ch = "".
  publish "GetDoubleClick" (output std-ch).
  if std-ch = "" or lookup(std-ch, tDoubleClick:list-item-pairs) = 0
   then std-ch = entry(2, tDoubleClick:list-item-pairs).
  tDoubleClick:screen-value = std-ch.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY tDefaultView tDoubleClick tDefaultStatus 
      WITH FRAME fConfig IN WINDOW C-Win.
  ENABLE rStartup rOptions tDefaultView tDoubleClick tDefaultStatus bSave 
         bCancel 
      WITH FRAME fConfig IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-fConfig}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

