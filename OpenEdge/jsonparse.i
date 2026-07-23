&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
@file jsonparse.i
@description Include to parse a json file

@param Root;char;The root element name (if not provided by JSON)

@author John Oliver
@created 11.12.2018
@note The JSON file is transformed into a XML file which is then natively
      parsed.
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&if defined(root) = 0 &then
&scoped-define root Root
&endif

&if defined(tool) = 0 &then
&scoped-define tool JSONConsole.exe
&endif

/* Variables ---                                                        */
define variable xmlFile as character no-undo.
define variable traceFile as character no-undo.
define variable curElementName as character no-undo.
define variable curElementValue as character no-undo.
{lib/std-def.i}

&if defined(has-namespace) = 0 &then
{lib/xmlparse.i &xmlFile=xmlFile &traceFile=traceFile &exclude-startElement=true}
&else
{lib/xmlparse.i &xmlFile=xmlFile &traceFile=traceFile &exclude-startElement=true &has-namespace=true}
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD parseJson Include 
FUNCTION parseJson RETURNS LOGICAL
  ( output pMsg as character )  FORWARD.

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

traceFile = "".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Characters Include 
PROCEDURE Characters :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pText as memptr no-undo.
  define input parameter pCharCount as int no-undo.
  
  curElementValue = curElementValue + get-string(pText, 1, pCharCount).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE jsonAddNewline Include 
PROCEDURE jsonAddNewline :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pFile as character no-undo.
  define variable mLine as memptr no-undo.
  
  input from value(pFile) binary.
  seek input to end.
  seek input to (seek(input) - 1).
  set-size(mLine) = 0.
  set-size(mLine) = 1.
  import unformatted mLine.
  input close.
  
  if get-byte(mLine,1) <> 10 then do:
    output to value(pFile) append.
    put unformatted "~n".
    output close.
  end.
  
  set-size(mLine) = 0.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&if defined(exclude-StartElement) = 0 &then

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartElement Include 
PROCEDURE StartElement :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  {lib/jsonstartelement.i}
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&endif

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION parseJson Include 
FUNCTION parseJson RETURNS LOGICAL
  ( output pMsg as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable pSuccess as logical no-undo initial true.
  define variable tool as character no-undo.
  define variable cmd as character no-undo.
  
  tool = search("prog\{&tool}").
  if tool = ?
   then
    do:
      pSuccess = false.
      pMsg = "{&tool} tool not found".
    end.
 
  file-info:file-name = {&jsonFile}.
  if file-info:full-pathname = ?
   then
    do:
      pSuccess = false.
      pMsg = "Input file data found".
    end.
    
  if pSuccess and file-info:file-size > 0
   then
    do:
      /* we need to add a newline character at the end of the file */
      run jsonAddNewline in this-procedure (file-info:full-pathname).
      
      xmlFile = file-info:full-pathname + "XML".
      cmd = tool + ' "' + file-info:full-pathname + '" "' + xmlFile + '" "' + '{&root}' + '"'.
      etime(true).
      os-command silent value(cmd).
      
      file-info:file-name = xmlFile.
      if file-info:full-pathname = ?
       then
        do:
          pSuccess = false.
          pMsg = "Could not transform JSON into XML".
        end.
      
      if pSuccess
       then
        do:
          pSuccess = parseXML(output pMsg).
          std-ch = replace(guid, "-", "") + "CMD".
          output to value(std-ch).
          put unformatted cmd.
          output close.
          publish "AddTempFile" ("{&tool}2", file-info:full-pathname).
          publish "AddTempFile" ("{&tool}5", std-ch).
          publish "AddTempFile" ("{&tool}7", {&jsonFile}).
          publish "ProcessLog" ("{&tool}", "PROGRAM", etime, pSuccess).
        end.
    end.
   
  RETURN pSuccess.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

