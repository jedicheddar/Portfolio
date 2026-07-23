&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
@file run-command-async.i
@description function to run a command file through the command line
Modification:
Name        Date          Comments
K.R         10/27/2025    Modified to to catch error
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD runCommandAsync Include 
FUNCTION runCommandAsync RETURNS LOGICAL
  ( input pCommand as character,
    input pRetries as integer )  FORWARD.

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


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION runCommandAsync Include 
FUNCTION runCommandAsync RETURNS LOGICAL
  ( input pCommand as character,
    input pRetries as integer ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable cLine as character no-undo.
  define variable iRetryCount as integer no-undo initial 1.
  define variable lSuccess as logical no-undo initial false.
  define variable chAppWScript as com-handle no-undo.
  define variable cErrorFile as character no-undo.

  chAppWScript = ?.
  cErrorFile = guid(generate-uuid).

  if pCommand = "" or pCommand = ?
   then return false.

  if pRetries = 0 or pRetries = ?
   then pRetries = 3.

  repeat while not lSuccess and iRetryCount <= pRetries on error undo,throw:
    release object chAppWScript no-error.
    chAppWScript = ?.
    create "Wscript.Shell":U chAppWScript.

    if valid-handle(chAppWScript)
     then
      do:
        message "Attempt " + string(iRetryCount) + " to run command " + pCommand + "..." view-as alert-box information.
        output to value(cErrorFile).
        chAppWScript:run(pCommand, 0).
        output close.
        message "Completed attempt " + string(iRetryCount) + " run of shell" view-as alert-box information.
        
        cLine = "".
        file-information:file-name = cErrorFile.
        if file-information:file-size > 0
         then
          do:
            input from value(cErrorFile).
            import unformatted cLine no-error.
            message cLine view-as alert-box information buttons ok.
            input close.
          end.
        
        if cLine > "" and index(cLine, "Error") > 0
         then .
         else lSuccess = true.
        
        if lSuccess
         then "...and resulted in success".
         else "...and resulted in failure: " + cLine.
        
        os-delete value(file-information:full-pathname).
      end.

    iRetryCount = iRetryCount + 1.

    catch oError as progress.lang.error:
      message oError:getmessage(1) skip pCommand
          view-as alert-box information buttons ok.

      run util/sysmail.p ("Failed to run async command",
                          substitute("Error: &1 <br> Command: &2", oError:getmessage(1), pCommand)).
    end catch.
  end.

  release object chAppWScript no-error.
  chAppWScript = ?.
  return lSuccess.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

