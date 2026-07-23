&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/* ***************************  Definitions  ************************** */

{lib/find-widget.i}
{lib/add-delimiter.i}

&if defined(addAll) = 0 &then
&scoped-define addAll false
&endif

&if defined(setEnable) = 0 &then
&scoped-define setEnable true
&endif

&if defined(innerLines) = 0 &then
&scoped-define innerLines 20
&endif

&if defined(maxLines) = 0 &then
&scoped-define maxLines 100
&endif

&if defined(t) = 0 &then
&scoped-define t agent
&endif

&if defined(n) = 0 &then
&scoped-define n name
&endif

&if defined(addUnknown) = 0 &then
&scoped-define addUnknown false
&endif

&if defined(addBlank) = 0 &then
&scoped-define addBlank false
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */


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

&if defined(combo) <> 0 &then
{&combo}:delimiter = {&msg-dlm}.
&if defined(noPublish) = 0 &then
publish "GetAgents" (output table {&t}).
&endif
/* create the text box */
{&combo}:tab-stop = false.
create fill-in std-ha assign
  frame           = {&combo}:frame
  row             = {&combo}:row
  column          = {&combo}:column
  width           = {&combo}:width
  format          = "x(500)"
  screen-value    = ""
  sensitive       = true
  read-only       = not {&setEnable}
  visible         = true
  name            = "{&combo}AgentText"
  tab-stop        = true
  triggers:
    on value-changed run AgentComboList in this-procedure (self:screen-value).
    on return apply "return" to {&combo} in frame {&frame-name}.
    on mouse-select-click
    do:
      if not self:read-only
       then apply "VALUE-CHANGED" to self.
    end.
  end triggers
  .
/* create a selection list widget (if not already there) */
if {&combo}:type = "COMBO-BOX"
 then
  do:
    create selection-list std-ha assign
      frame              = {&combo}:frame
      row                = {&combo}:row + {&combo}:height
      column             = {&combo}:column
      width              = {&combo}:width
      inner-lines        = 1
      scrollbar-vertical = true
      sensitive          = true
      visible            = false
      name               = "{&combo}AgentSelection"
      tab-stop           = false
      triggers:
        on return apply "mouse-select-click" to self.
        on mouse-select-click
        do:
          if not self:screen-value = "..."
           then run AgentComboSet in this-procedure (self:screen-value).
        end.
      end triggers
      .
    std-ha:delimiter = {&msg-dlm}.
    std-ha:list-item-pairs = "ALL" {&msg-add} "ALL".
    std-ha:delete(1).
    if {&addUnknown}
     then
      {&combo}:list-item-pairs = "Unknown" + {&combo}:delimiter + "Unknown".   
  end.
 else
  do:
    assign
      std-ha = {&combo}:handle
      std-ha:row = std-ha:row + 1.3
      std-ha:inner-lines = std-ha:inner-lines - 2
      .
  end.
/* trigger to close the agent selection list */
&if defined(noCloseTrigger) = 0 &then
on entry anywhere
do:
  run AgentComboClose in this-procedure.
end.
on mouse-select-down of frame {&frame-name}
do:
  apply "ENTRY" to self.
end.
&endif
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _procedure AgentComboClear Include 
PROCEDURE AgentComboClear :
/*------------------------------------------------------------------------------
@description Clears the selected agent from the agent list
------------------------------------------------------------------------------*/
  do with frame {&frame-name}:
    std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    if valid-handle(std-ha)
     then 
      do:
        std-ha:screen-value = "".
        apply "ENTRY" to std-ha.
      end.
    
    {&combo}:list-item-pairs = "ALL" + {&combo}:delimiter + "ALL".
    {&combo}:delete(1).
    if {&addUnknown}
     then
      {&combo}:list-item-pairs = "Unknown" + {&combo}:delimiter + "Unknown". 
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _procedure AgentComboClose Include 
PROCEDURE AgentComboClose :
/*------------------------------------------------------------------------------
@description Closes the agent list
------------------------------------------------------------------------------*/
  define variable hSelection as handle no-undo.
  define variable hText as handle no-undo.
  
  hSelection = GetWidgetByName({&combo}:frame in frame {&frame-name}, "{&combo}AgentSelection").
  hText = GetWidgetByName({&combo}:frame in frame {&frame-name}, "{&combo}AgentText").
  if valid-handle(hSelection) and valid-handle(hText)
   then
    if not self:name = "{&combo}AgentText" and not self:name = "{&combo}AgentSelection"
     then hSelection:visible = false.
     else
      do:
        if hSelection:list-item-pairs > "" and not hSelection:visible
         then hSelection:visible = true.
      end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _procedure AgentComboDebug Include 
PROCEDURE AgentComboDebug :
/*------------------------------------------------------------------------------
@description Messages the information
------------------------------------------------------------------------------*/
  define variable hText as handle no-undo.
  define variable hSelection as handle no-undo.
  
  do with frame {&frame-name}:
    hText = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    hSelection = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
    if valid-handle(hText) and valid-handle(hSelection)
     then message "Text Value: " + hText:screen-value skip
                  "Visible: " + string(hSelection:visible) skip
                  "List: " + hSelection:list-item-pairs view-as alert-box information buttons ok.
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _procedure AgentComboEnable Include 
PROCEDURE AgentComboEnable :
/*------------------------------------------------------------------------------
@description Enables/Disables the agent fill-in
------------------------------------------------------------------------------*/
  define input parameter pEnable as logical no-undo.
  
  do with frame {&frame-name}:
    std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    if valid-handle(std-ha)
     then
      do:
        std-ha:read-only = not pEnable.
        std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
        if valid-handle(std-ha)
         then std-ha:visible = false.
      end.
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AgentComboGetName Include 
PROCEDURE AgentComboGetName :
/*------------------------------------------------------------------------------
@description Get the agent name 
------------------------------------------------------------------------------*/
  define input  parameter piAgentID  as character no-undo.
  define output parameter poAgentID  as character no-undo.
  define output parameter pAgentName as character no-undo.
  
  assign
    poAgentID  = ""
    pAgentName = ""
    .
  for first {&t} no-lock
      where {&t}.agentID = piAgentID:
    
    assign
      poAgentID  = {&t}.agentID
      pAgentName = {&t}.{&n}
      .
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _procedure AgentComboHide Include 
PROCEDURE AgentComboHide :
/*------------------------------------------------------------------------------
@description Hides/Shows the agent fill-in
------------------------------------------------------------------------------*/
  define input parameter pHide as logical no-undo.
  
  do with frame {&frame-name}:
    std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    if valid-handle(std-ha)
     then
      do:
        std-ha:visible = not pHide.
        std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
        if valid-handle(std-ha)
         then std-ha:visible = false.
      end.
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AgentComboList Include 
PROCEDURE AgentComboList :
/*------------------------------------------------------------------------------
@description Get the agent list
------------------------------------------------------------------------------*/
  define input parameter pAgentFilter as character no-undo.
  define variable cFirst  as character no-undo.
  define variable cList   as character no-undo.
  define variable iAgents as integer   no-undo.
  define variable iFilter as integer   no-undo.
  define variable hBox    as handle    no-undo.

  do with frame {&frame-name}:
    std-lo = {&combo}:type = "COMBO-BOX".
    if std-lo
     then hBox = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
     else hBox = {&combo}:handle.
    
    if valid-handle(hBox)
     then
      do:
        assign
          hBox:visible = true
          cList        = ""
          cFirst       = "ALL" + hBox:delimiter + "ALL"
          iAgents      = (if {&addAll} or {&addBlank} then 1 else 0)
          .
          
        if {&addUnknown}
         then hBox:add-last("Unknown","Unknown").  
          
        if {&addBlank}
         then cList = "" + hBox:delimiter + "".  
          
        for each {&t} no-lock
              by {&t}.{&n}:
          
          
          if pAgentFilter > "" and not ({&t}.{&n} matches "*" + pAgentFilter + "*" or {&t}.agentID begins pAgentFilter)
           then next.
          
          if {&t}.{&n} = "Unknown Prospects"
           then next.
          
          &if defined(state) <> 0 &then
          if {&state}:screen-value <> "ALL" and {&state}:screen-value <> "Unknown" and {&state}:screen-value <> {&t}.stateID
           then next.
          &endif
          
          &if defined(stat) <> 0 &then
          if {&stat}:screen-value <> "ALL" and {&stat}:screen-value <> {&t}.stat
           then next.
          &endif
          
          &if defined(manager) <> 0 &then
          if {&manager}:screen-value <> "ALL" and {&manager}:screen-value <> {&t}.manager
           then next.
          &endif
          
          &if defined(region) <> 0 &then
          if {&region}:screen-value <> "ALL" and {&region}:screen-value <> {&t}.regionID
           then next.
          &endif
          
          iAgents = iAgents + 1.
          if iAgents > {&maxLines} - (if {&addAll} then 2 else 1)
           then next.
          
          cList = addDelimiter(cList, hBox:delimiter) + {&t}.{&n} + " (" + {&t}.agentID + ")" + hBox:delimiter + {&t}.agentID.
        end.

        /* add the ... option */
        if iAgents > {&maxLines} - (if {&addAll} then 2 else 1)
         then
          do:
            cList = addDelimiter(cList, hBox:delimiter) + "..." + hBox:delimiter + "...".
            if {&combo}:type = "COMBO-BOX"
             then hBox:inner-lines = minimum(iAgents, minimum({&innerLines}, integer({&combo}:frame:height - {&combo}:row - {&combo}:height))).
          end.
         else
          do:
            if {&combo}:type = "COMBO-BOX"
             then
              do:
                hBox:inner-lines = minimum(iAgents, minimum({&innerLines}, integer({&combo}:frame:height - {&combo}:row - {&combo}:height))).
                if iAgents = 0
                 then hBox:visible = false.
              end.
          end.

        /* add the ALL option */
        if {&addAll}
         then 
          if cList > ""
           then cList = cFirst + hBox:delimiter + cList.
           else cList = cFirst.
         
        if cList > ""
         then hBox:list-item-pairs = cList.
      end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AgentComboResize Include 
PROCEDURE AgentComboResize :
/*------------------------------------------------------------------------------
@description The user resizes the agent selection
------------------------------------------------------------------------------*/
  define variable hText as handle no-undo.
  define variable hSelection as handle no-undo.

  do with frame {&frame-name}:
    hText = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    hSelection = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
    if valid-handle(hText)
     then
      do:
        assign
          hText:row    = {&combo}:row
          hText:column = {&combo}:column
          hText:width  = {&combo}:width
          .
        hText:move-to-top().
      end.
    if valid-handle(hSelection)
     then
      assign
        hSelection:row    = {&combo}:row + {&combo}:height
        hSelection:column = {&combo}:column
        hSelection:width  = {&combo}:width
        .
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AgentComboSet Include 
PROCEDURE AgentComboSet :
/*------------------------------------------------------------------------------
@description Set an agent in both the drop down and text box
------------------------------------------------------------------------------*/
  define input parameter pAgentID as character no-undo.
  define variable cAgentID as character no-undo.
  define variable cAgentName as character no-undo.
  define variable lFound as logical no-undo initial false.
  
  do with frame {&frame-name}:
    {&combo}:list-item-pairs = "ALL" + {&combo}:delimiter + "ALL".
    for first {&t} no-lock
        where {&t}.agentID = pAgentID:
      
      assign
        lFound = true
        cAgentID = {&t}.agentID
        cAgentName = {&t}.{&n}
        .
    end.
    /* set the main combo */
    if lFound
     then
      assign
        {&combo}:list-item-pairs = cAgentName + {&combo}:delimiter + cAgentID
        {&combo}:screen-value = cAgentID
        .
     else if {&addUnknown}
      then
       assign
         {&combo}:list-item-pairs = "Unknown" + {&combo}:delimiter + "Unknown"
         {&combo}:screen-value    = "Unknown".
     else    
      {&combo}:screen-value = "ALL".
    
    /* the textbox */
    std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    if valid-handle(std-ha)
     then std-ha:screen-value = (if lFound then cAgentName + " (" + cAgentID + ")" else (if {&addAll} then "ALL" else (if {&addUnknown} then "Unknown" else std-ha:screen-value))).
    
    /* the selection list */
    std-ha = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
    if valid-handle(std-ha)
     then std-ha:visible = false.
    
    &if defined(noApply) = 0 &then
    if pAgentID > ""
     then apply "VALUE-CHANGED" to {&combo}.
    &endif
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE AgentComboState Include 
PROCEDURE AgentComboState :
/*------------------------------------------------------------------------------
@description The user selected a new state
------------------------------------------------------------------------------*/
  define variable hText      as handle no-undo.
  define variable hSelection as handle no-undo.

  do with frame {&frame-name}:
    hText = GetWidgetByName({&combo}:frame, "{&combo}AgentText").
    hSelection = GetWidgetByName({&combo}:frame, "{&combo}AgentSelection").
    if valid-handle(hText)
     then
      do:
        run AgentComboClear in this-procedure.
        hText:screen-value = "".
        hSelection:visible = false.
      end.
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

