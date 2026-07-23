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
{lib/do-wait.i}
{lib/find-widget.i}
{lib/move-item.i}
{lib/move-item-order.i}
{lib/add-delimiter.i}
{lib/build-browse.i}
{tt/listentity.i}
{tt/listfield.i}
{tt/listentity.i &tableAlias="userentity"}
{tt/listfield.i &tableAlias="userfield"}
{tt/listfilter.i &tableAlias="userfilter"}

define input parameter hSource as handle no-undo.
define input parameter pIsNew as logical no-undo.
  
/* variables used for the dynamic filter */
define variable hFilter as widget-handle.
define variable iTotalRow as integer no-undo initial 0.
define variable iDisplayRow as integer no-undo initial 0.
define variable iSpace as decimal no-undo initial 1.3.
define variable iFrame as decimal no-undo.
define variable cCurrDisplayName as character no-undo initial "".

&scoped-define FLabel "FilterRow"
&scoped-define FField "cmbFieldRow"
&scoped-define FOperator "cmbOperRow"
&scoped-define FValue "txtValueRow"

/* dynamic results */
define variable listresult as handle no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME frmBuild

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS bClear bExport bRun RECT-1 bSave bAddFilter ~
tEntity tRptName tFieldList tDisplayList bAddField bMoveUp bRemoveField ~
bMoveDown 
&Scoped-Define DISPLAYED-OBJECTS tEntity tRptName tFieldList tDisplayList 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetFieldDataType C-Win 
FUNCTION GetFieldDataType RETURNS CHARACTER
  ( input pColumnBuffer as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetFieldFilterList C-Win 
FUNCTION GetFieldFilterList RETURNS CHARACTER
  ( input pEntity as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetFieldList C-Win 
FUNCTION GetFieldList RETURNS CHARACTER
  ( )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetResultCount C-Win 
FUNCTION GetResultCount RETURNS INTEGER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD GetRowNumber C-Win 
FUNCTION GetRowNumber RETURNS INTEGER
  ( INPUT cRow AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD SensitizeButtons C-Win 
FUNCTION SensitizeButtons RETURNS LOGICAL
  ( input pEnable as logical )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ValidateFilter C-Win 
FUNCTION ValidateFilter RETURNS CHARACTER
  ( INPUT iRow AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bAddField 
     LABEL ">" 
     SIZE 4.8 BY 1.14 TOOLTIP "Add the selected field to Quick List".

DEFINE BUTTON bAddFilter 
     LABEL "Add" 
     SIZE-PIXELS 24 BY 24 TOOLTIP "Add a filter to the Quick List".

DEFINE BUTTON bClear  NO-FOCUS
     LABEL "Clear" 
     SIZE 7.2 BY 1.71 TOOLTIP "Clear the field(s) and filter(s)".

DEFINE BUTTON bExport  NO-FOCUS
     LABEL "Export" 
     SIZE 7.2 BY 1.71 TOOLTIP "Export the Quick List to Excel".

DEFINE BUTTON bMoveDown 
     LABEL "^" 
     SIZE 4.8 BY 1.14 TOOLTIP "Move the selected field down".

DEFINE BUTTON bMoveUp 
     LABEL "^" 
     SIZE 4.8 BY 1.14 TOOLTIP "Move the selected field up".

DEFINE BUTTON bRemoveField 
     LABEL "<" 
     SIZE 4.8 BY 1.14 TOOLTIP "Delete the selected field from Quick List".

DEFINE BUTTON bRun  NO-FOCUS
     LABEL "Run" 
     SIZE 7.2 BY 1.71 TOOLTIP "Run the Quick List with the selected field(s) and filter(s)".

DEFINE BUTTON bSave  NO-FOCUS
     LABEL "Save" 
     SIZE 7.2 BY 1.71 TOOLTIP "Save the field(s) and filter(s)".

DEFINE VARIABLE tEntity AS CHARACTER FORMAT "X(256)":U 
     LABEL "Entity" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Table","Table"
     DROP-DOWN-LIST
     SIZE 25 BY 1 TOOLTIP "Select a table" NO-UNDO.

DEFINE VARIABLE tRptName AS CHARACTER FORMAT "X(256)":U 
     LABEL "List Name" 
     VIEW-AS FILL-IN 
     SIZE 44.2 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 192 BY 8.1.

DEFINE VARIABLE tDisplayList AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
     LIST-ITEM-PAIRS "item1","item1" 
     SIZE 30 BY 6.38 TOOLTIP "The columns that will appear in the Quick List" NO-UNDO.

DEFINE VARIABLE tFieldList AS CHARACTER 
     VIEW-AS SELECTION-LIST MULTIPLE SCROLLBAR-VERTICAL 
     LIST-ITEM-PAIRS "item1","item1" 
     SIZE 30 BY 6.38 TOOLTIP "The available columns to display in the Quick List" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME frmBuild
     bClear AT ROW 1.14 COL 23.2 WIDGET-ID 122
     bExport AT ROW 1.14 COL 16 WIDGET-ID 118
     bRun AT ROW 1.14 COL 1.6 WIDGET-ID 116
     bSave AT ROW 1.14 COL 8.8 WIDGET-ID 120
     bAddFilter AT Y 74 X 204 WIDGET-ID 42
     tEntity AT ROW 4.62 COL 14 COLON-ALIGNED WIDGET-ID 64
     tRptName AT ROW 4.62 COL 61 COLON-ALIGNED WIDGET-ID 74
     tFieldList AT ROW 4.62 COL 119 NO-LABEL WIDGET-ID 104
     tDisplayList AT ROW 4.62 COL 156.6 NO-LABEL WIDGET-ID 110
     bAddField AT ROW 6.52 COL 150.4 WIDGET-ID 106
     bMoveUp AT ROW 6.52 COL 188 WIDGET-ID 124
     bRemoveField AT ROW 7.95 COL 150.4 WIDGET-ID 108
     bMoveDown AT ROW 7.95 COL 188 WIDGET-ID 126
     "Columns to Display:" VIEW-AS TEXT
          SIZE 19 BY .62 AT ROW 3.91 COL 157 WIDGET-ID 114
     "Criteria" VIEW-AS TEXT
          SIZE 6.6 BY .62 AT ROW 3.14 COL 3 WIDGET-ID 70
     "Available Columns:" VIEW-AS TEXT
          SIZE 18 BY .62 AT ROW 3.91 COL 119 WIDGET-ID 112
     RECT-1 AT ROW 3.38 COL 2 WIDGET-ID 68
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 194 BY 29.29 WIDGET-ID 100.

DEFINE FRAME frmBrowse
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 11.81
         SIZE 194 BY 18.48 WIDGET-ID 500.

DEFINE FRAME frmFilter
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 4 ROW 5.71
         SIZE 113 BY 5.43 WIDGET-ID 400.


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
         TITLE              = "Quick List Builder"
         HEIGHT             = 29.29
         WIDTH              = 194
         MAX-HEIGHT         = 38.57
         MAX-WIDTH          = 246.6
         VIRTUAL-HEIGHT     = 38.57
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
/* REPARENT FRAME */
ASSIGN FRAME frmBrowse:FRAME = FRAME frmBuild:HANDLE
       FRAME frmFilter:FRAME = FRAME frmBuild:HANDLE.

/* SETTINGS FOR FRAME frmBrowse
                                                                        */
/* SETTINGS FOR FRAME frmBuild
   FRAME-NAME                                                           */
ASSIGN 
       bClear:PRIVATE-DATA IN FRAME frmBuild     = 
                "Delete".

ASSIGN 
       bExport:PRIVATE-DATA IN FRAME frmBuild     = 
                "Delete".

ASSIGN 
       bRun:PRIVATE-DATA IN FRAME frmBuild     = 
                "Delete".

ASSIGN 
       bSave:PRIVATE-DATA IN FRAME frmBuild     = 
                "Delete".

/* SETTINGS FOR FRAME frmFilter
                                                                        */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Quick List Builder */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* Quick List Builder */
DO:
  run WindowResized in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bAddField
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bAddField C-Win
ON CHOOSE OF bAddField IN FRAME frmBuild /* > */
DO:
  do with frame frmBuild:
    MoveItem(tFieldList:handle,tDisplayList:handle,",").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bAddFilter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bAddFilter C-Win
ON CHOOSE OF bAddFilter IN FRAME frmBuild /* Add */
DO:
  RUN AddFilter IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bClear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bClear C-Win
ON CHOOSE OF bClear IN FRAME frmBuild /* Clear */
DO:
  run ClearData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bExport
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bExport C-Win
ON CHOOSE OF bExport IN FRAME frmBuild /* Export */
DO:
  run ExportData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bMoveDown
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bMoveDown C-Win
ON CHOOSE OF bMoveDown IN FRAME frmBuild /* ^ */
DO:
  do with frame frmBuild:
    MoveItemOrder(tDisplayList:handle,false,",").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bMoveUp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bMoveUp C-Win
ON CHOOSE OF bMoveUp IN FRAME frmBuild /* ^ */
DO:
  do with frame frmBuild:
    MoveItemOrder(tDisplayList:handle,true,",").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bRemoveField
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bRemoveField C-Win
ON CHOOSE OF bRemoveField IN FRAME frmBuild /* < */
DO:
  do with frame frmBuild:
    MoveItem(tDisplayList:handle,tFieldList:handle,",").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bRun
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bRun C-Win
ON CHOOSE OF bRun IN FRAME frmBuild /* Run */
DO:
  run GetData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bSave
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bSave C-Win
ON CHOOSE OF bSave IN FRAME frmBuild /* Save */
DO:
  run SaveData in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tDisplayList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tDisplayList C-Win
ON DEFAULT-ACTION OF tDisplayList IN FRAME frmBuild
DO:
  do with frame frmBuild:
    MoveItem(tDisplayList:handle,tFieldList:handle,",").
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tEntity
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tEntity C-Win
ON VALUE-CHANGED OF tEntity IN FRAME frmBuild /* Entity */
DO:
  run ChangeTable in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tFieldList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tFieldList C-Win
ON DEFAULT-ACTION OF tFieldList IN FRAME frmBuild
DO:
  do with frame frmBuild:
    MoveItem(tFieldList:handle,tDisplayList:handle,",").
  end.
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
  /* create the images for the buttons */
  do with frame frmBuild:
    bSave:load-image-up("images/save.bmp").
    bSave:load-image-insensitive("images/save-i.bmp").
    bRun:load-image-up("images/import.bmp").
    bRun:load-image-insensitive("images/import-i.bmp").
    bExport:load-image-up("images/excel.bmp").
    bExport:load-image-insensitive("images/excel-i.bmp").
    bClear:load-image-up("images/blank.bmp").
    bClear:load-image-insensitive("images/blank-i.bmp").
    bAddFilter:load-image-up("images/s-add.bmp").
    bAddFilter:load-image-insensitive("images/s-add-i.bmp").
    bMoveUp:load-image-up("images/s-up.bmp").
    bMoveUp:load-image-insensitive("images/s-up-i.bmp").
    bMoveDown:load-image-up("images/s-down.bmp").
    bMoveDown:load-image-insensitive("images/s-down-i.bmp").
    bAddField:load-image-up("images/s-right.bmp").
    bAddField:load-image-insensitive("images/s-right-i.bmp").
    bRemoveField:load-image-up("images/s-left.bmp").
    bRemoveField:load-image-insensitive("images/s-left-i.bmp").
    tFieldList:delete(1).
    tDisplayList:delete(1).
    tEntity:delete(1).
    iFrame = frame frmFilter:virtual-height.
  end.
  RUN enable_UI.
  run Initialize in this-procedure.
      
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AddFilter C-Win 
PROCEDURE AddFilter :
/*------------------------------------------------------------------------------
  Purpose:    Adds a filter to the filter frame 
  Parameters: <none>
  Notes:       
------------------------------------------------------------------------------*/
  define variable iColumn as decimal extent no-undo initial [5.5,13.0,39.0,60.0,105.0].
  define variable iWidth as decimal no-undo initial 0.0.
  define variable iLength as integer no-undo.
  define variable iOffset as decimal no-undo.
  
  if iDisplayRow = 15
   then
    do:
      message "You cannot add more than 15 filters" view-as alert-box warning buttons ok.
      return.
    end.

  /* add one to the new row counter */
  assign
    iTotalRow = iTotalRow + 1
    iDisplayRow = iDisplayRow + 1
    .
  
  if iDisplayRow > 4
   then
    do:
      assign
        iLength = length(string(iDisplayRow))
        iOffset = if iLength > 1 then 0.6 * iLength else 0
        std-de = frame frmFilter:virtual-height + iSpace
        frame frmFilter:virtual-height = std-de
        .
      run util/RemoveHScrollbar.p (frame frmFilter:handle).
    end.
  
  do std-in = 1 to extent(iColumn):
    assign
      iWidth = iColumn[std-in + 1] - iColumn[std-in] - 1.0 
      no-error
      .
    case std-in:
     when 1 then /* label */
      create text hFilter assign
        frame         = frame frmfilter:handle
        row           = iSpace * iDisplayRow
        column        = iColumn[std-in] - iOffset
        width-chars   = iWidth + iOffset
        height-chars  = 1.0
        data-type     = "character"
        format        = "x(12)"
        screen-value  = "Filter " + string(iDisplayRow) + ":"
        sensitive     = true
        visible       = true
        name          = {&FLabel} + string(iTotalRow)
        .
     when 2 then /* field combo-box */
      do:
        create combo-box hFilter assign
          frame         = frame frmfilter:handle
          row           = iSpace * iDisplayRow
          column        = iColumn[std-in]
          width         = iWidth
          inner-lines   = 6
          data-type     = "character"
          format        = "x(256)"
          sensitive     = true
          visible       = true
          name          = {&FField} + string(iTotalRow)
          triggers:
            on value-changed persistent run ChangeField in this-procedure(iTotalRow).
          end triggers.
          .
        hFilter:list-item-pairs = GetFieldFilterList(tEntity:screen-value in frame frmBuild).
      end.
     when 3 then /* operand combo-box */
      create combo-box hFilter assign
        frame         = frame frmfilter:handle
        row           = iSpace * iDisplayRow
        column        = iColumn[std-in]
        width         = iWidth
        inner-lines   = 6
        sensitive     = true
        visible       = true
        name          = {&FOperator} + string(iTotalRow)
        .
     when 4 then /* value fill-in */
      create fill-in hFilter assign
        frame         = frame frmfilter:handle
        row           = iSpace * iDisplayRow
        column        = iColumn[std-in]
        width         = iWidth
        data-type     = "character"
        format        = "x(256)"
        sensitive     = true
        visible       = true
        name          = {&FValue} + string(iTotalRow)
        .
     otherwise /* buttons */
      do:
        /* create the Remove button */
        create button hFilter assign
          frame         = frame frmfilter:handle
          row           = (iSpace * iDisplayRow) - 0.1
          column        = iColumn[std-in]
          width-chars   = 4.80
          height-chars  = 1.14
          sensitive     = true
          visible       = true
          name          = "btnRemoveRow" + string(iTotalRow)
          triggers:
            on choose persistent run RemoveFilter in this-procedure (iTotalRow).
          end triggers.
          .
        hFilter:load-image-up("images/s-delete.bmp").
        hFilter:load-image-insensitive("images/s-delete-i.bmp").
      end.
    end case.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE BuildData C-Win 
PROCEDURE BuildData :
/*------------------------------------------------------------------------------
@description Builds the filters and fields from the passed in report title
------------------------------------------------------------------------------*/
  define input parameter pDisplayName as character no-undo.
  define input parameter pReportName as character no-undo.
  define input parameter pAutoRun as logical no-undo.
  define buffer userfilter for userfilter.
  define buffer userfield for userfield.
  
  define variable iFilterCounter as integer no-undo initial 0.
  
  SensitizeButtons(false).
  do with frame frmBuild:
    assign
      tRptName:screen-value = pDisplayName
      cCurrDisplayName = pDisplayName
      .
    publish "OpenList" (pReportName,
                        output table userfield,
                        output table userfilter,
                        output std-lo).
                        
    
    if not std-lo
     then message "Could not open the saved report" view-as alert-box error buttons ok.
     else
      do:
        /* add the field(s) */
        for each userfield 
              by userfield.order:
          
          if userfield.order = 1
           then
            do:
              publish "GetEntityFields" (userfield.entityName, output table listfield).
              assign
                tFieldList:list-item-pairs = GetFieldList()
                tEntity:screen-value = userfield.entityName
                .
            end.
          
          if can-find(first listfield where tableName = userfield.tableName and columnBuffer = userfield.columnBuffer)
           then
            do:
              tFieldList:screen-value = userfield.columnBuffer.
              MoveItem(tFieldList:handle,tDisplayList:handle,",").
            end.
        end.
        /* scroll both lists to the top */
        tFieldList:scroll-to-item(1).
        tDisplayList:scroll-to-item(1).

        /* add the filter(s) */
        iFilterCounter = 0.
        for each userfilter:
          if can-find(first listfield where tableName = userfilter.tableName and columnBuffer = userfilter.tableName + "_" + userfilter.columnName)
           then
            do:
              iFilterCounter = iFilterCounter + 1.
              /* we first need to add a filter row */
              run AddFilter in this-procedure.
              
              /* the field combo box */
              hFilter = GetWidgetByName(frame frmFilter:handle,{&FField} + string(iFilterCounter)).
              hFilter:screen-value = userfilter.tableName + "_" + userfilter.columnName.
              run ChangeField in this-procedure (iFilterCounter).
              
              /* the operand combo box */
              hFilter = GetWidgetByName(frame frmFilter:handle,{&FOperator} + string(iFilterCounter)).
              hFilter:screen-value = userfilter.columnOperator.
              
              /* the value fill-in */
              hFilter = GetWidgetByName(frame frmFilter:handle,{&FValue} + string(iFilterCounter)).
              hFilter:screen-value = userfilter.columnValue.
            end.
        end.
        SensitizeButtons(false).
        
        /* build the list data */
        if pAutoRun
         then
          do:
            pause 1 no-message.
            apply "CHOOSE":U to bRun.
          end.
      end.
  end.
  SensitizeButtons(true).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangeField C-Win 
PROCEDURE ChangeField :
/*------------------------------------------------------------------------------
@description When a user changes the field for the particular filter 
@param Row;character;The row that we need to modify
------------------------------------------------------------------------------*/
  define input parameter iRow as integer.
  define variable cEntity as character no-undo.
  define variable cDataType as character no-undo initial "".
  define variable cOperList as character no-undo initial "Is,=,Is Not,!=".
  define variable hField as widget-handle.
  
  cEntity = tEntity:screen-value in frame frmBuild.
  hField = GetWidgetByName(frame frmFilter:handle,{&FField} + string(iRow)).
  if valid-handle(hField)
   then cDataType = GetFieldDataType(hField:screen-value).
  
  if cDataType > ""
   then
    case cDataType:
     when "character" then cOperList = cOperList + ",Contains,LIKE".
     when "integer" or
     when "decimal" or
     when "datetime" then cOperList = cOperList + ",Is Greater Than,>,Is Less Than,<".
     when "logical" then cOperList = cOperList.
    end case.
  
  hField = GetWidgetByName(frame frmFilter:handle,{&FOperator} + string(iRow)).
  if valid-handle(hField)
   then hField:list-item-pairs = cOperList.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangeTable C-Win 
PROCEDURE ChangeTable :
/*------------------------------------------------------------------------------
@description The user changed the table so we need to change the filter criteria
------------------------------------------------------------------------------*/
  define variable cEntity as character no-undo.
  define variable iCounter as integer no-undo.
  define variable hField as widget-handle.
  do with frame frmBuild:
    cEntity = tEntity:screen-value in frame frmBuild.
    
    /* remove all filters */
    do std-in = iTotalRow to 1 by -1:
      run RemoveFilter in this-procedure (std-in).
    end.
    
    /* change the available fields based on the table */
    publish "GetEntityFields" (cEntity, output table listfield).
    tFieldList:list-item-pairs = GetFieldList().
    
    /* remove all of the columns from the displayed field list */
    do std-in = num-entries(tDisplayList:list-item-pairs) / 2 to 1 by -1:
      tDisplayList:delete(std-in).
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ClearData C-Win 
PROCEDURE ClearData :
/*------------------------------------------------------------------------------
@description Clears any selections that the user may have made   
------------------------------------------------------------------------------*/
  /* remove all the filters */
  std-ha = frame frmFilter:first-child:first-child.
  repeat while valid-handle(std-ha):
    hFilter = std-ha.
    std-ha = std-ha:next-sibling.
    if valid-handle(hFilter)
     then delete widget hFilter.
  end.
  assign
    iTotalRow = 0
    iDisplayRow = 0
    std-ch = ""
    .
  
  status input "".
  status default "".
  
  /* clear the displayed fields, report name, and table */
  do with frame frmBuild:
    publish "GetCurrentValue" ("Entity", output std-ch).
    if lookup(std-ch,tEntity:list-item-pairs) > 0
     then tEntity:screen-value = std-ch.
     else tEntity:screen-value = entry(2,tEntity:list-item-pairs).
    apply "VALUE-CHANGED" to tEntity.
  end.
  
  /* empty the temporary tables */
  empty temp-table userentity.
  empty temp-table userfilter.
  empty temp-table userfield.
    
  /* rebuild the browse */
  publish "BuildEmptyTable" (std-ch, output listresult, output table userfield).
  /* the only column in the dynamic table is the keyfield with no data */
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
  DISPLAY tEntity tRptName tFieldList tDisplayList 
      WITH FRAME frmBuild IN WINDOW C-Win.
  ENABLE bClear bExport bRun RECT-1 bSave bAddFilter tEntity tRptName 
         tFieldList tDisplayList bAddField bMoveUp bRemoveField bMoveDown 
      WITH FRAME frmBuild IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmBuild}
  VIEW FRAME frmFilter IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-frmFilter}
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
  
  /* validate that there is a title */
  do with frame frmBuild:
    if tRptName:screen-value > ""
     then cReportName = "Report_" + tRptName:screen-value.
     else cReportName = "Table_" + tEntity:screen-value.
  end.
  
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
  define variable cError as character no-undo initial "".
  define variable cEntity as character no-undo.
  
  define variable lFieldSuccess as logical no-undo.
  define variable lFilterSuccess as logical no-undo.
  
  /* get the table */
  cEntity = tEntity:screen-value in frame frmBuild.
  if cEntity = ?
   then
    do:
      MESSAGE "Please select a table" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
      return.
    end.
  
  /* get the action for the table */
  for first listentity no-lock
      where listentity.entityName = cEntity:
      
    create userentity.
    buffer-copy listentity to userentity.
  end.
  
  /* save the display fields */
  run SaveFields in this-procedure (output lFieldSuccess).
  
  /* save the filters */
  run SaveFilters in this-procedure (output lFilterSuccess).
  
  /* if there is nothing wrong with the filters */
  if lFilterSuccess and lFieldSuccess
   then 
    do:
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
                                             cEntity).
                                             
          status input string(GetResultCount()) + " row(s) returned".
          status default string(GetResultCount()) + " row(s) returned".
        end.
       else message "Could not retrieve report data" view-as alert-box error buttons ok.
    end.
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Initialize C-Win 
PROCEDURE Initialize :
/*------------------------------------------------------------------------------
@description Sets the window on the initial open  
------------------------------------------------------------------------------*/  
  SensitizeButtons(false).
  do with frame frmBuild:
    /* get the allowed tables for the user */
    publish "GetEntities" (output table listentity,
                           output std-lo).
    
    if not std-lo
     then 
      do:
        message "No data returned from the server" view-as alert-box error buttons ok.
        return.
      end.
      
    /* set the combo box of the tables */
    tEntity:delete(1).
    for each listentity no-lock:

      tEntity:add-last(listentity.displayName,listentity.entityName).
    end.
    
    apply "CHOOSE":U to bClear.
  end.
  SensitizeButtons(true).
  status input "".
  status default "".
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RemoveFilter C-Win 
PROCEDURE RemoveFilter :
/*------------------------------------------------------------------------------
@description Removes a row from the filter frame
@param Row;integer;The row that we need to remove
@notes
------------------------------------------------------------------------------*/
  define input parameter iRow as integer.
  
  define variable lRemoved as logical no-undo initial false.
  define variable iDisplay as integer no-undo.
  define variable hFilter as handle no-undo.
  
  std-ha = frame frmFilter:first-child:first-child.
  repeat while valid-handle(std-ha):
    lRemoved = true.
    std-in = GetRowNumber(std-ha:name).
    if std-in = iRow
     then 
      do:
        hFilter = std-ha.
        if index(std-ha:name,{&FLabel}) > 0 and std-ha:type = "text"
         then 
          assign
            std-ch = substring(std-ha:screen-value,7)
            iDisplay = integer(substring(std-ch,1,index(std-ch,":") - 1))
            .
      end.
    
    if std-in > iRow
     then
      do:
        std-ha:row = std-ha:row - iSpace.
        if index(std-ha:name,{&FLabel}) > 0 and std-ha:type = "text"
         then 
          assign
            std-ha:screen-value = "Filter " + string(iDisplay) + ":"
            iDisplay = iDisplay + 1.
            .
      end.
    
    std-ha = std-ha:next-sibling.
    
    if valid-handle(hFilter)
     then delete widget hFilter.
  end.
  if lRemoved
   then iDisplayRow = iDisplayRow - 1.
  /* subtract the height of the virtual-frame if available */
  std-de = frame frmFilter:virtual-height - iSpace.
  if std-de < iFrame
   then frame frmFilter:virtual-height = iFrame.
   else frame frmFilter:virtual-height = std-de.
  /* we need to take away from the virtual height as we removed a filter */
  if iDisplayRow > 4
   then run util/RemoveHScrollbar.p (frame frmFilter:handle).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaveData C-Win 
PROCEDURE SaveData :
/*------------------------------------------------------------------------------
@description Saves the filter and display selections in a file  
------------------------------------------------------------------------------*/  
  define variable cDisplayName as character no-undo.
  define variable cFilterFile as character no-undo.
  define variable cFieldFile as character no-undo.
  define variable cResultFile as character no-undo.
  
  define variable lFieldSuccess as logical no-undo.
  define variable lFilterSuccess as logical no-undo.
  
  /* get the report name */
  cDisplayName = tRptName:screen-value in frame frmBuild.
  if cDisplayName <> ? and cDisplayName <> ""
   then
    do:
      /* save the filters and fields to temp-tables */
      run SaveFilters in this-procedure (output lFieldSuccess).
      run SaveFields in this-procedure (output lFilterSuccess).
      if not lFieldSuccess or not lFilterSuccess
       then return.
       
      /* set always-on-top to true then false after saving */
      {&window-name}:always-on-top = true.
      run SaveSavedList in hSource (pIsNew,
                                    cCurrDisplayName,
                                    cDisplayName,
                                    table userfield,
                                    table userfilter).
      {&window-name}:always-on-top = false.
    end.
   else MESSAGE "Please provide a report name" VIEW-AS ALERT-BOX INFO BUTTONS OK.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaveFields C-Win 
PROCEDURE SaveFields :
/*------------------------------------------------------------------------------
@description Save the fields that the user has added for the report       
------------------------------------------------------------------------------*/
  define output parameter pSuccess as logical no-undo initial false.
  
  define variable columnBuffer as character no-undo.
  
  empty temp-table userfield.
  do with frame frmBuild:
    do std-in = 1 to num-entries(tDisplayList:list-item-pairs) / 2:
      columnBuffer = entry(std-in * 2,tDisplayList:list-item-pairs).
      create userfield.
      for first listfield no-lock
          where listfield.columnBuffer = columnBuffer:
        
        buffer-copy listfield to userfield.
        for first userfield exclusive-lock
            where userfield.columnBuffer = columnBuffer:
            
          userfield.order = std-in.
        end.
        pSuccess = true.
      end.
    end.
  end.
  
  if not pSuccess
   then MESSAGE "Please select at least one column to display" VIEW-AS ALERT-BOX ERROR BUTTONS OK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaveFilters C-Win 
PROCEDURE SaveFilters :
/*------------------------------------------------------------------------------
@description Saves the filters into a temp table  
------------------------------------------------------------------------------*/
  define output parameter pSuccess as logical no-undo initial false.
  
  define variable hField as widget-handle.
  define variable hOper as widget-handle.
  define variable hValue as widget-handle.
  define variable cField as character no-undo.
  define variable cOper as character no-undo.
  define variable cValue as character no-undo.
  define variable cRow as character no-undo.
  define variable cError as character no-undo.
  
  /* loop through all of the rows even though some may be deleted */
  empty temp-table userfilter.
  do std-in = 1 to iTotalRow:
    cRow = ValidateFilter(std-in).
    /* lc-max means that the row is not there as it's possible that a filter can be deleted */
    if cRow <> lc-max
     then
      if cRow = ""
       then
        do:
          create userfilter.
          assign
            hField = GetWidgetByName(frame frmFilter:handle,{&FField} + string(std-in))
            hOper = GetWidgetByName(frame frmFilter:handle,{&FOperator} + string(std-in))
            hValue = GetWidgetByName(frame frmFilter:handle,{&FValue} + string(std-in))
            cField = hField:screen-value
            cOper = hOper:screen-value
            cValue = hValue:screen-value
            userfilter.tableName = entry(1,cField,"_")
            userfilter.columnName = entry(2,cField,"_")
            userfilter.columnOperator = cOper
            userfilter.columnValue = cValue
            .
          release userfilter.
        end.
       else cError = cError + cRow.
  end.
  
  if cError > ""
   then MESSAGE cError view-as alert-box error buttons ok.
   else pSuccess = true.
   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE WindowResized C-Win 
PROCEDURE WindowResized :
/*------------------------------------------------------------------------------
@description Executes when the window is resized, either bigger or smaller 
------------------------------------------------------------------------------*/  
  frame frmBuild:width-pixels = {&window-name}:width-pixels.
  frame frmBuild:virtual-width-pixels = {&window-name}:width-pixels.
  frame frmBuild:height-pixels = {&window-name}:height-pixels.
  frame frmBuild:virtual-height-pixels = {&window-name}:height-pixels.

  /* modify the frame for the dynamic browse */
  frame frmBrowse:width-pixels = {&window-name}:width-pixels.
  frame frmBrowse:virtual-width-pixels = {&window-name}:width-pixels.
  frame frmBrowse:height-pixels = {&window-name}:height-pixels - frame frmBrowse:y.
  frame frmBrowse:virtual-height-pixels = {&window-name}:height-pixels - frame frmBrowse:y.
  
  /* rebuild the result browse */
  if GetResultCount() = 0
   then empty temp-table userfield.
   else
    for first userfield:
      std-ch = userfield.entityName.
    end.
   
  if valid-handle(listresult)
   then run BuildBrowse in this-procedure (listresult,
                                           temp-table userfield:handle,
                                           frame frmBrowse:handle,
                                           std-ch).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetFieldDataType C-Win 
FUNCTION GetFieldDataType RETURNS CHARACTER
  ( input pColumnBuffer as character ) :
/*------------------------------------------------------------------------------
@description Get the datatype for a given column
------------------------------------------------------------------------------*/
  define variable cDataType as character no-undo.
  for first listfield no-lock
      where listfield.columnBuffer = pColumnBuffer:
     
    cDataType = listfield.dataType.
  end.
  RETURN lower(cDataType).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetFieldFilterList C-Win 
FUNCTION GetFieldFilterList RETURNS CHARACTER
  ( input pEntity as character ) :
/*------------------------------------------------------------------------------
@description Gets the list of fields in a comma-delimited string for use in the
             Filter combo box
------------------------------------------------------------------------------*/
  define variable fieldList as character no-undo.
  
  for each listfield no-lock
     where listfield.tableName = pEntity
        by listfield.displayName:
    if listfield.queryFunction = ""
     then fieldList = addDelimiter(fieldList,",") + 
                      trim(listfield.displayName) + "," + 
                      listfield.columnBuffer.
  
  end.
  if fieldList = ""
   then fieldList = " , ".
  RETURN replace(fieldList,"!"," ").   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetFieldList C-Win 
FUNCTION GetFieldList RETURNS CHARACTER
  ( ) :
/*------------------------------------------------------------------------------
@description Gets the list of fields in a comma-delimited string
------------------------------------------------------------------------------*/
  define variable fieldList as character no-undo.
  
  for each listfield no-lock
        by listfield.displayName:
    if listfield.queryFunction <> "key"
     then fieldList = addDelimiter(fieldList,",") + 
                      trim(listfield.displayName) + "," + 
                      listfield.columnBuffer.
  end.
  if fieldList = ""
   then fieldList = " , ".
  RETURN replace(fieldList,"!"," ").   /* Function return value. */
  
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION GetRowNumber C-Win 
FUNCTION GetRowNumber RETURNS INTEGER
  ( INPUT cRow AS CHARACTER ) :
/*------------------------------------------------------------------------------
@description Extract the row number from the filter field's name
@returns The row number 
@notes
------------------------------------------------------------------------------*/
  define variable ind as integer no-undo.
  ind = index(cRow, "Row").
  ind = integer(substring(cRow,ind + 3)) no-error.
  RETURN ind.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION SensitizeButtons C-Win 
FUNCTION SensitizeButtons RETURNS LOGICAL
  ( input pEnable as logical ) :
/*------------------------------------------------------------------------------
@description Enables or disables the buttons
------------------------------------------------------------------------------*/
  DoWait(not pEnable).
  do with frame frmBuild:
    assign
      bSave:sensitive = pEnable
      bRun:sensitive = pEnable
      bExport:sensitive = pEnable
      bClear:sensitive = pEnable
      bAddFilter:sensitive = pEnable
      bAddField:sensitive = pEnable
      bRemoveField:sensitive = pEnable
      bMoveUp:sensitive = pEnable
      bMoveDown:sensitive = pEnable
      tEntity:sensitive = pEnable
      tRptName:read-only = not pEnable
      .
      
    /* disable all the filters */
    std-ha = frame frmFilter:first-child:first-child.
    repeat while valid-handle(std-ha):
      if std-ha:type = "fill-in"
       then std-ha:read-only = not pEnable.
       else std-ha:sensitive = pEnable.
      std-ha = std-ha:next-sibling.
    end.
  end.
  RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ValidateFilter C-Win 
FUNCTION ValidateFilter RETURNS CHARACTER
  ( INPUT iRow AS INTEGER ) :
/*------------------------------------------------------------------------------
@description Validates the user's filters
@returns True if the filters are valid; false otherwise
------------------------------------------------------------------------------*/
  define variable hDisplay as widget-handle.
  define variable hField as widget-handle.
  define variable hOper as widget-handle.
  define variable hValue as widget-handle.
  define variable cRow as character no-undo initial "".
  define variable cDisplay as character no-undo.
  define variable cField as character no-undo.
  define variable cOper as character no-undo.
  define variable cValue as character no-undo.
  define variable cEntity as character no-undo.
  define variable cDataType as character no-undo.
  
  &scoped-define tab "    "
  define variable nl as character no-undo initial "~n".
  
  /* get all the widgets by the name and the table name */
  hDisplay = GetWidgetByName(frame frmFilter:handle,{&FLabel} + string(iRow)).
  hField = GetWidgetByName(frame frmFilter:handle,{&FField} + string(iRow)).
  hOper = GetWidgetByName(frame frmFilter:handle,{&FOperator} + string(iRow)).
  hValue = GetWidgetByName(frame frmFilter:handle,{&FValue} + string(iRow)).
  cEntity = tEntity:screen-value in frame frmBuild.
  /* if the display is there, then the rest of the row is there */
  if hDisplay <> ?
   then
    do:
      /* get the screen values */
      cDisplay = hDisplay:screen-value.
      cField = hField:screen-value.
      cOper = hOper:screen-value.
      cValue = hValue:screen-value.
      
      if cField = ?
       then cRow = cRow + {&tab} + "The field cannot be blank." + nl.
      
      if cOper = ?
       then cRow = cRow + {&tab} + "The operand cannot be blank." + nl.
      
      /* the validation is dependent on the datatype */
      cDataType = GetFieldDataType(cField).
      if cDataType > ""
       then
        case cDataType:
         when "integer" then
          do:
            integer(cValue) no-error.
            if error-status:error or cValue = ""
             then cRow = cRow + {&tab} + "The value is not an integer." + nl.
          end.
         when "decimal" then
          do:
            decimal(cValue) no-error.
            if error-status:error or cValue = ""
             then cRow = cRow + {&tab} + "The value is not an decimal." + nl.
          end.
         when "datetime" then 
          do:
            datetime(cValue) no-error.
            if error-status:error
             then cRow = cRow + {&tab} + "The value is not a valid date." + nl.
          end.
         when "logical" then
          do:
            cValue = upper(cValue).
            if cValue <> "TRUE" and cValue <> "FALSE"
             then cRow = cRow + {&tab} + "The value is not TRUE or FALSE." + nl.
          end.
        end case.
      
      /* if there is an error with the filter, place the row that has the problem before the error */
      if cRow > ""
       then cRow = cDisplay + nl + cRow + nl.
    end.
   else cRow = lc-max.
  
  return cRow.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

