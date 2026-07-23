&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include
/*------------------------------------------------------------------------
@file dialog-config-def.i
@description Configuration include definition for all the common dialog elements

@author John Oliver
@created 08.25.2020

@notes Use in conjunction with the following include files (in Main Block):

       {lib/dialog-config-add-load.i} for adding a load startup checkbox
       {lib/dialog-config-add-file.i} for adding a file retrieval box
       {lib/dialog-config-add-checkbox.i} for adding a checkbox
       {lib/dialog-config-add-radio.i} for adding a radio box
       
       Only a certain amount of generated elements allowed:
       
       16 Startup Load Checkboxes
       2  Radio Boxes
       2  Directory System Textboxes
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* variables */
&scoped-define MaxStartup 16
&scoped-define MaxRadio 2
&scoped-define MaxFile 2
{lib/std-def.i}

/* functions */
{lib/text-align.i}

/* used to hold the elements */
define temp-table config-item
  field itemWidget   as widget-handle
  field itemButton   as widget-handle
  field itemLabel    as character     format "x(100)"
  field itemLoadProc as character     format "x(100)"
  field itemGetProc  as character     format "x(100)"
  field itemSetProc  as character     format "x(100)"
  field itemModProc  as character     format "x(100)"
  field itemType     as character     format "x(100)"
  field itemOptions  as character     format "x(100)"
  field itemTooltip  as character     format "x(1000)"
  field isMandatory  as logical
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD saveConfig Include  _DB-REQUIRED
FUNCTION saveConfig RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setConfig Include
FUNCTION setConfig RETURNS LOGICAL
  ( input hFrame   as handle,
    input hStartup as handle,
    input hOptions as handle )  FORWARD.

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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetOptionsFile Include
PROCEDURE GetOptionsFile :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter itemWidget as handle no-undo.

  std-ch = itemWidget:screen-value.
  if itemWidget:screen-value > ""
    then system-dialog get-dir std-ch title "Select a Directory..." initial-dir std-ch.
    else system-dialog get-dir std-ch title "Select a Directory...".

  if std-ch > "" and std-ch <> ?
   then itemWidget:screen-value = std-ch.
   
  run SaveConfigTrigger in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadStartup Include
PROCEDURE LoadStartup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter itemLabel as character no-undo.
  define input parameter loadProc  as character no-undo.
  define input parameter modProc   as character no-undo.

  publish loadProc.
  message itemLabel + " Reloaded" view-as alert-box information buttons ok.
  publish modProc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadStartupAll Include
PROCEDURE LoadStartupAll :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer config-item for config-item.

  session:set-wait-state("GENERAL").
  for each config-item no-lock
     where config-item.itemType = "Startup":

    publish config-item.itemLoadProc.
  end.
  message "All Entities Reloaded" view-as alert-box information buttons ok.
  session:set-wait-state("").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ToggleStartupCheckboxes Include
PROCEDURE ToggleStartupCheckboxes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter hAll as widget-handle no-undo.
  define buffer config-item for config-item.

  for each config-item no-lock
     where config-item.itemType = "Startup":

    if valid-handle(config-item.itemWidget) and config-item.itemWidget:type = "TOGGLE-BOX" and not config-item.isMandatory
     then config-item.itemWidget:checked = hAll:checked.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaveConfigTrigger Include
PROCEDURE SaveConfigTrigger :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  &if defined(onChange) <> 0 &then
  saveConfig().
  &endif

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION saveConfig Include
FUNCTION saveConfig RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  /* buffer */
  define buffer config-item for config-item.
  for each config-item no-lock
        by config-item.itemType
        by config-item.itemLabel:

    case config-item.itemType:
     when "File"     or
     when "Radio"    then
      do:
        if valid-handle(config-item.itemWidget)
         then publish config-item.itemSetProc (config-item.itemWidget:input-value).
      end.
     when "Startup"  then
      do:
        &if defined(useNew) = 0 &then
        if valid-handle(config-item.itemWidget)
         then publish config-item.itemSetProc (config-item.itemWidget:checked).
        &else
        if valid-handle(config-item.itemWidget)
         then publish "SetLoad" (config-item.itemLoadProc, config-item.itemWidget:input-value).
        &endif
      end.
     when "Checkbox" then
      do:
        if valid-handle(config-item.itemWidget)
         then publish config-item.itemSetProc (config-item.itemWidget:checked).
      end.
    end case.
  end.
  RETURN FALSE.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setConfig Include
FUNCTION setConfig RETURNS LOGICAL
  ( input hFrame   as handle,
    input hStartup as handle,
    input hOptions as handle ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  /* common variables */
  define variable hDummyWidget  as widget-handle no-undo.

  /* variables for the Load on Startup checkboxes */
  define variable iStartupCounter      as integer no-undo initial 0.
  define variable iStartupNumber       as integer no-undo initial 0.
  define variable iStartupRow          as integer no-undo.
  define variable lStartupFirstCol     as logical no-undo.
  &scoped-define StartupStartRow (hStartup:row + 1.13)
  &scoped-define StartupFirstCol (hStartup:column + 3.00)
  &scoped-define StartupSecondCol (hStartup:column + (hStartup:width-chars / 2) + 1)
  &scoped-define StartupSpaceBetweenRow ((hStartup:height-chars - {&StartupStartRow}) / ((if iStartupNumber modulo 2 = 0 then iStartupNumber else iStartupNumber - 1) / 2))
  &scoped-define StartupLabelWidth ((hStartup:width-chars - 15.6) / 2 - 1)

  /* variables for the file options */
  define variable iFileCounter  as integer no-undo initial 0.
  define variable iFileNumber   as integer no-undo initial 0.
  define variable iFileRow      as integer no-undo.
  &scoped-define FileStartRow (hOptions:row + 0.71)
  &scoped-define FileStartCol (hOptions:column + 3.00)
  &scoped-define FileSpaceBetweenRow 1.24
  &scoped-define FileLabelWidth 20.00

  /* variables for the checkbox options */
  define variable iCheckboxCounter as integer no-undo initial 0.
  define variable iCheckboxNumber  as integer no-undo initial 0.
  define variable iCheckboxRow     as integer no-undo.
  define variable iCheckboxCol     as integer no-undo.
  &scoped-define CheckboxStartRow ((hOptions:height / 2) + hOptions:row)
  &scoped-define CheckboxFirstCol (hOptions:column + 3.00)
  &scoped-define CheckboxSpaceBetweenRow 1
  &scoped-define CheckboxLabelWidth (hOptions:width-chars / 5)
  
  /* variables for the radio button options */
  define variable iRadioCounter   as integer no-undo initial 0.
  define variable iRadioNumber    as integer no-undo initial 0.
  define variable iRadioRow       as integer no-undo.
  define variable lRadioFirstCol  as logical no-undo.
  define variable dRadioFirstCol  as decimal no-undo.
  define variable dRadioSecondCol as decimal no-undo.
  &scoped-define RadioStartRow ((hOptions:height / 2) + hOptions:row + 0.10)
  &scoped-define RadioLabelWidth (hOptions:width-chars / 5)

  /* buffer */
  define buffer config-item for config-item.
  
  /* validation */
  for each config-item no-lock:
    case config-item.itemType:
     when "Radio"    then iRadioCounter    = iRadioCounter + 1.
     when "Checkbox" then iCheckboxCounter = iCheckboxCounter + 1.
     when "File"     then iFileCounter     = iFileCounter + 1.
     when "Startup"  then iStartupCounter  = iStartupCounter + 1.
    end.
  end.
  
  if iRadioCounter > {&MaxRadio}
   then return false.
  
  if iFileCounter > {&MaxFile}
   then return false.
  
  if iStartupCounter > {&MaxStartup}
   then return false.
   
  /* save the number of items */
  assign
    iStartupNumber  = iStartupCounter
    iRadioNumber    = iRadioCounter
    iCheckboxNumber = iCheckboxCounter
    iFileNumber     = iFileCounter
    .
  
  /* reset the counters */
  assign
    iRadioCounter    = 0
    iCheckboxCounter = 0
    iFileCounter     = 0
    iStartupCounter  = 0
    .
    
  for each config-item no-lock
        by config-item.itemType
        by config-item.itemLabel:

    case config-item.itemType:
     when "Radio" then
      do:
        assign
          iRadioCounter   = iRadioCounter + 1
          lRadioFirstCol  = (if iRadioCounter modulo 2 > 0 then true else false) 
          dRadioFirstCol  = {&CheckboxFirstCol} + (minimum(3, iCheckboxNumber) * {&RadioLabelWidth})
          dRadioSecondCol = dRadioFirstCol + {&RadioLabelWidth}
          .
        /* create a label */
        create text hDummyWidget assign
          frame        = hFrame
          format       = "x(100)"
          width        = {&RadioLabelWidth} - 4
          screen-value = config-item.itemLabel
          column       = (if lRadioFirstCol then dRadioFirstCol else dRadioSecondCol)
          row          = {&RadioStartRow}
          sensitive    = true
          visible      = true
          .
        /* create the radio set */
        create radio-set config-item.itemWidget assign
          frame         = hFrame
          radio-buttons = config-item.itemOptions
          column       = (if lRadioFirstCol then dRadioFirstCol else dRadioSecondCol) + 1
          row          = {&RadioStartRow} + hDummyWidget:height + 0.1
          sensitive    = true
          visible      = true
          triggers:
            on value-changed persistent run SaveConfigTrigger in this-procedure.
          end triggers.
          .
        /* get the data for the radio set */
        std-ch = "".
        publish config-item.itemGetProc (output std-ch).
        if lookup(config-item.itemOptions, std-ch) > 0
         then config-item.itemWidget:screen-value = std-ch.
      end.
     when "Checkbox" then
      do:
        assign
          iCheckboxCounter = iCheckboxCounter + 1
          std-lo           = (iCheckboxCounter modulo (5 - iRadioNumber) = 0)
          iCheckboxRow     = truncate(iCheckboxCounter / (5 - iRadioNumber), 0) + (if std-lo then 0 else 1)
          iCheckboxCol     = (if std-lo then 5 - iRadioNumber else iCheckboxCounter modulo (5 - iRadioNumber))
          std-in           = length(config-item.itemLabel) + 3
          .
        /* create the checkbox */
        create toggle-box config-item.itemWidget assign
          frame     = hFrame
          name      = "tConfigCheckbox" + replace(config-item.itemLabel, " ", "")
          row       = {&CheckboxStartRow} + ((iCheckboxRow - 1) * {&CheckboxSpaceBetweenRow})
          column    = {&CheckboxFirstCol} + ((iCheckboxCol - 1) * {&CheckboxLabelWidth})
          label     = (if std-in > {&CheckboxLabelWidth} then substring(config-item.itemLabel, 1, integer(integer({&CheckboxLabelWidth}) / 2)) + "..." else config-item.itemLabel)
          width     = (if std-lo then {&CheckboxLabelWidth} - 4 else {&CheckboxLabelWidth})
          tooltip   = (if std-in > {&CheckboxLabelWidth} then config-item.itemLabel + (if config-item.itemTooltip > "" then ": " else "") + config-item.itemTooltip else config-item.itemTooltip)
          sensitive = (if config-item.isMandatory then false else true)
          checked   = (if config-item.isMandatory then true else false)
          visible   = true
          triggers:
            on value-changed persistent run SaveConfigTrigger in this-procedure.
          end triggers.
          .
        /* get the data for the checkbox */
        std-lo = false.
        publish config-item.itemGetProc (output std-lo).
        config-item.itemWidget:checked = std-lo.
      end.
     when "File" then
      do:
        iFileCounter = iFileCounter + 1.
        /* create a side label widget */
        create text hDummyWidget assign
          frame        = hFrame
          format       = "x(100)"
          screen-value = config-item.itemLabel + ":"
          column       = {&FileStartCol}
          row          = {&FileStartRow} + ((iFileCounter - 1) * {&FileSpaceBetweenRow}) + 0.15
          tooltip      = config-item.itemTooltip
          sensitive    = true
          visible      = true
          width        = {&FileLabelWidth}
          .
        rightAlignText(hDummyWidget).
        /* create the text box */
        create fill-in config-item.itemWidget assign
          frame        = hFrame
          name         = "tConfigOptions" + replace(config-item.itemLabel, " ", "")
          row          = {&FileStartRow} + ((iFileCounter - 1) * {&FileSpaceBetweenRow})
          column       = {&FileStartCol} + hDummyWidget:width + 1
          width        = hOptions:width-chars - {&FileStartCol} - hDummyWidget:width - 6.3
          height       = 1.00
          format       = "x(100)"
          sensitive    = true
          visible      = true
          .
        config-item.itemWidget:side-label-handle = hDummyWidget.
        /* create the button */
        create button config-item.itemButton assign
          frame        = hFrame
          row          = {&FileStartRow} + ((iFileCounter - 1) * {&FileSpaceBetweenRow}) - 0.10
          column       = config-item.itemWidget:column + config-item.itemWidget:width-chars + 0.5
          sensitive    = true
          visible      = true
          width        = 4.8
          height       = 1.14
          label        = "..."
          triggers:
            on choose persistent run GetOptionsFile in this-procedure (config-item.itemWidget).
          end triggers.
          .
        /* get the data for the file */
        std-ch = "".
        publish config-item.itemGetProc (output std-ch).
        config-item.itemWidget:screen-value = std-ch.
      end.
     when "Startup" then
      do:
        assign
          iStartupCounter      = iStartupCounter + 1
          iStartupRow          = round(iStartupCounter / 2, 0)
          lStartupFirstCol     = (if iStartupCounter modulo 2 > 0 then true else false)
          std-in               = length(config-item.itemLabel) + 4
          .
        /* create the checkbox */
        create toggle-box config-item.itemWidget assign
          frame     = hFrame
          name      = "tConfigStartup" + replace(config-item.itemLabel, " ", "")
          row       = {&StartupStartRow} + ((iStartupRow - 1) * {&StartupSpaceBetweenRow})
          column    = (if lStartupFirstCol then {&StartupFirstCol} else {&StartupSecondCol})
          label     = (if std-in > {&StartupLabelWidth} then substring(config-item.itemLabel, 1, integer(integer({&StartupLabelWidth}) / 2)) + "..." else config-item.itemLabel)
          width     = {&StartupLabelWidth}
          tooltip   = (if std-in > {&StartupLabelWidth} then config-item.itemLabel + (if config-item.itemTooltip > "" then ": " else "") + config-item.itemTooltip else config-item.itemTooltip)
          sensitive = (if config-item.isMandatory then false else true)
          checked   = (if config-item.isMandatory then true else false)
          visible   = true
          triggers:
            on value-changed persistent run SaveConfigTrigger in this-procedure.
          end triggers.
          .
        /* get the data for the checkbox */
        std-lo = false.
        &if defined(useNew) = 0 &then
        publish config-item.itemGetProc (output std-lo).
        &else
        publish "GetLoad" (config-item.itemLoadProc, output std-lo).
        &endif
        std-lo = std-lo or config-item.isMandatory.
        config-item.itemWidget:checked = std-lo.
        /* create the button */
        create button config-item.itemButton assign
          frame     = hFrame
          row       = {&StartupStartRow} + ((iStartupRow - 1) * {&StartupSpaceBetweenRow}) - 0.15
          column    = (if lStartupFirstCol then {&StartupFirstCol} else {&StartupSecondCol}) + {&StartupLabelWidth}
          sensitive = true
          visible   = true
          tooltip   = "Reload " + config-item.itemLabel
          width     = 4.8
          height    = 1.14
          triggers:
            on choose persistent run LoadStartup in this-procedure (config-item.itemLabel, config-item.itemLoadProc, config-item.itemModProc).
          end triggers.
          .
        /* set the image */
        config-item.itemButton:load-image("images/s-sync.bmp").
        config-item.itemButton:load-image-insensitive("images/s-sync-i.bmp").
      end.
    end case.
  end.

  /* add the all option in the load startup */
  assign
    iStartupCounter  = iStartupCounter + 1
    iStartupRow      = round(iStartupCounter / 2, 0)
    lStartupFirstCol = (if iStartupCounter modulo 2 > 0 then true else false)
    .
  create toggle-box hDummyWidget assign
    frame     = hFrame
    name      = "tConfigStartupAll"
    row       = {&StartupStartRow} + ((iStartupRow - 1) * {&StartupSpaceBetweenRow})
    column    = (if lStartupFirstCol then {&StartupFirstCol} else {&StartupSecondCol})
    label     = "ALL"
    sensitive = true
    checked   = false
    visible   = true
    triggers:
      on value-changed persistent run ToggleStartupCheckboxes in this-procedure (hDummyWidget:handle).
    end triggers.
    .
  create button hDummyWidget assign
    frame     = hFrame
    row       = {&StartupStartRow} + ((iStartupRow - 1) * {&StartupSpaceBetweenRow}) - 0.15
    column    = (if lStartupFirstCol then {&StartupFirstCol} else {&StartupSecondCol}) + {&StartupLabelWidth}
    sensitive = true
    visible   = true
    tooltip   = "Reload all the entities"
    width     = 4.8
    height    = 1.14
    triggers:
      on choose persistent run LoadStartupAll in this-procedure.
    end triggers.
    .
  hDummyWidget:load-image("images/s-sync.bmp").
  hDummyWidget:load-image-insensitive("images/s-sync-i.bmp").

  return true.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

