&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
@file dialog-config-add-load.i
@description Add a checkbox to the Load on Startup rectangle

@author John Oliver
@created 08.25.2020
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&if defined(mandatory) = 0 &then
&scoped-define mandatory false
&endif

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

create config-item.
assign
  config-item.itemLabel   = "{&label}"
  config-item.isMandatory = {&mandatory}
  config-item.itemTooltip = "{&tooltip}"
  config-item.itemType    = "Checkbox"
  std-ch                  = replace(config-item.itemLabel, " ", "")
  .
  
&if defined(getProc) = 0 &then
config-item.itemGetProc = "Get" + std-ch.
&else
config-item.itemGetProc = "{&getProc}".
&endif
  
&if defined(setProc) = 0 &then
config-item.itemSetProc = "Set" + std-ch.
&else
config-item.itemSetProc = "{&setProc}".
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


