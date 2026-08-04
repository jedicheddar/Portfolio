&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*---------------------------------------------------------------------
@name arc-repository-procedures.i
@description Procedures for getting the Repository data from the ARC

@author John Oliver
@version 1.0
@created 07.10.2020
@notes 
@Modified :
Date        Name          Comments   
11/28/2025 S Chandu      Modified to  uplaod file with displayname using 'UploadFileWithDispName'.
---------------------------------------------------------------------*/

/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* variables */
define variable tURL          as character no-undo.
define variable tTraceFile    as character no-undo.
define variable tResponseFile as character no-undo.
define variable tHeader       as character no-undo.
define variable tAuth         as character no-undo.
{lib/add-delimiter.i}
{lib/xmlencode.i}
{lib/tt-xml.i &CSharp=true}
{lib/std-def.i}

/* These are used inside xml/xmlparse.i */
&scoped-define traceFile tTraceFile
&scoped-define xmlFile tResponseFile

{lib/xmlparse.i &exclude-startElement=true}

/* temp tables */
{tt/repository.i &tableAlias="arc-input-document"}
{tt/repository.i &tableAlias="arc-output-document"}

/* functions */
{lib/add-delimiter.i}
{lib/bearer-token.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getAuthorization Include 
FUNCTION getAuthorization RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getURL Include 
FUNCTION getURL RETURNS CHARACTER
  ( input pRepository as character )  FORWARD.

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

tAuth = getAuthorization().

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeleteFile Include 
PROCEDURE DeleteFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter pId      as character no-undo.
  define output parameter pSuccess as logical   no-undo.
  define output parameter pMsg     as character no-undo.
  
  /* post file */
  define variable tPostFile as character no-undo initial "DeleteFile.json".
  define variable tIDList   as character no-undo.
  do std-in = 1 to num-entries(pId):
    tIDList = addDelimiter(tIDList, ",") + "~"" + entry(std-in, pId) + "~"".
  end.

  /* the URL */
  tURL = getURL("DeleteFile").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"ids~": [" + tIDList + "]" skip.
  put unformatted "~}" skip.
  output close.

  /* header */
  tHeader = tAuth.
  
  /* call the ARC */
  run util/httppostdelete.p 
     (input  "ARCRepoFileDelete",
      input  tURL,
      input  tHeader,
      input  "application/json",
      input  tPostFile,
      output pSuccess,
      output pMsg,
      output tResponseFile).
  
  /* parse the XML */
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DownloadFile Include 
PROCEDURE DownloadFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input        parameter pId      as character no-undo.
  define input-output parameter pFile    as character no-undo.
  define       output parameter pSuccess as logical   no-undo.
  define       output parameter pMsg     as character no-undo.
  
  /* variables */
  define variable tFile as character no-undo.
  tFile = pFile.

  /* the URL */
  tURL = getURL("Download").
  tURL = replace(tURL, "&1", encodeUrl(pId)).

  /* header */
  tHeader = tAuth.
  
  /* call the ARC */
  run util/httpget.p 
     (input  "ARCRepoFileDownload",
      input  tURL,
      input  tHeader,
      output pSuccess,
      output pMsg,
      output tResponseFile).
      
  pFile = "".
  publish "GetTempDir" (output pFile).
  if pFile = ""
   then publish "GetSystemParameter" ("dataRoot", OUTPUT pFile).
  pFile = pFile + tFile.
  copy-lob file tResponseFile to file pFile.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetFiles Include 
PROCEDURE GetFiles :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter pEntity     as character no-undo.
  define input  parameter pEntityID   as character no-undo. 
  define input  parameter pOnlyPublic as logical   no-undo initial false.
  define output parameter table       for arc-output-document.
  define output parameter pSuccess    as logical   no-undo.
  define output parameter pMsg        as character no-undo.

  /* the URL */
  tURL = getURL("GetFiles").
  tURL = replace(tURL, "&1", encodeUrl(pEntity)).
  tURL = replace(tURL, "&2", encodeUrl(pEntityID)).
  tURL = replace(tURL, "&3", encodeUrl((if pOnlyPublic then "true" else "false"))).

  /* header */
  tHeader = "Accept:application/xml".
  if tAuth > ""
   then tHeader = tHeader + "," + tAuth.
  
  /* call the ARC */
  run util/httpget.p 
     (input  "ARCRepoFilesGet",
      input  tURL,
      input  tHeader,
      output pSuccess,
      output pMsg,
      output tResponseFile).
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ModifyFile Include 
PROCEDURE ModifyFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter table for arc-input-document.
  define output parameter table for arc-output-document.
  define output parameter pSuccess  as logical   no-undo.
  define output parameter pMsg      as character no-undo.
  
  /* buffer */
  define buffer document for arc-input-document.

  /* local variables */
  define variable xDoc  as handle    no-undo.
  define variable tFile as character no-undo.

  /* create an xml */
  publish "GetTempDir" (output tFile).
  if tFile = ""
   then publish "GetSystemParameter" ("dataRoot", OUTPUT tFile).
  tFile = tFile + "ARCRepositoryModifyFile.xml".

  xDoc = createXml("documents", "document", 'for each document').

  xDoc:save("file", tFile).
  delete object xDoc.

  /* the URL */
  tURL = getURL("ModifyFile").

  /* header */
  tHeader = "Accept:application/xml,".
  if tAuth > ""
   then tHeader = tHeader + "," + tAuth.
  
  /* call the ARC */
  run util/httppost.p 
     (input  "ARCRepoModifyFile",
      input  tURL,
      input  tHeader,
      input  "application/xml",
      input  tFile,
      output pSuccess,
      output pMsg,
      output tResponseFile).
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SaveFile Include 
PROCEDURE SaveFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter table for arc-input-document.
  define output parameter table for arc-output-document.
  define output parameter pSuccess  as logical   no-undo.
  define output parameter pMsg      as character no-undo.
  
  /* buffer */
  define buffer document for arc-input-document.

  /* local variables */
  define variable xDoc  as handle    no-undo.
  define variable tFile as character no-undo.

  /* create an xml */
  publish "GetTempDir" (output tFile).
  if tFile = ""
   then publish "GetSystemParameter" ("dataRoot", OUTPUT tFile).
  tFile = tFile + "ARCRepositorySaveFile.xml".

  xDoc = createXml("documents", "document", 'for each document').

  xDoc:save("file", tFile).
  delete object xDoc.

  /* the URL */
  tURL = getURL("SaveFile").

  /* header */
  tHeader = "Accept:application/xml,".
  if tAuth > ""
   then tHeader = tHeader + "," + tAuth.
  
  /* call the ARC */
  run util/httppost.p
     (input  "ARCRepoSaveFile",
      input  tURL,
      input  tHeader,
      input  "application/xml",
      input  tFile,
      output pSuccess,
      output pMsg,
      output tResponseFile).
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&IF defined(exclude-startElement) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE startElement Include 
PROCEDURE startElement :
/*------------------------------------------------------------------------------
  Purpose:     SAX Parser standard interface method
  Parameters:  
------------------------------------------------------------------------------*/
  {lib/get-temp-table.i &t=arc-output-document &setParam="'CompassDocument'"}
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UploadFile Include 
PROCEDURE UploadFile :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter pUser     as character no-undo.
  define input  parameter pPrivate  as logical   no-undo.
  define input  parameter pEntity   as character no-undo.
  define input  parameter pEntityID as character no-undo.
  define input  parameter pCategory as character no-undo.
  define input  parameter pFile     as character no-undo.
  define output parameter table for arc-output-document.
  define output parameter pSuccess  as logical   no-undo.
  define output parameter pMsg      as character no-undo.
  
  /* variable */
  define variable tFilename as character no-undo.
  define variable tCopyFile as character no-undo.
  
  /* make sure the file is valid */
  file-info:file-name = pFile.
  if file-info:full-pathname = ?
   then
    do:
      pSuccess = false.
      pMsg = "File " + pFile + " not found".
      return.
    end.
    
  /* get the filename */
  tFilename = entry(num-entries(pFile, "\"), pFile, "\").

  /* copy the file */
  publish "GetTempDir" (output tCopyFile).
  if tCopyFile = ""
   then publish "GetSystemParameter" ("dataRoot", OUTPUT tCopyFile).
  tCopyFile = tCopyFile + tFilename.
  os-copy value(pFile) value(tCopyFile).

  /* the URL */
  tURL = getURL("Upload").
  tURL = replace(tURL, "&1", encodeUrl(tFilename)).
  tURL = replace(tURL, "&2", encodeUrl(pUser)).
  tURL = replace(tURL, "&3", encodeUrl((if pPrivate then "true" else "false"))).
  tURL = replace(tURL, "&4", encodeUrl(pEntity)).
  tURL = replace(tURL, "&5", encodeUrl(pEntityID)).
  tURL = replace(tURL, "&6", encodeUrl(pCategory)).

  /* header */
  tHeader = "Accept:application/xml".
  if tAuth > ""
   then tHeader = tHeader + "," + tAuth.
  
      
  /* call the ARC */
  run util/httppost.p 
     (input  "ARCRepoFileUpload",
      input  tURL,
      input  tHeader,
      input  "application/octet-stream",
      input  tCopyFile,
      output pSuccess,
      output pMsg,
      output tResponseFile).

  if pMsg > ""
   then return.
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UploadFileWithDispName Include 
PROCEDURE UploadFileWithDispName :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
 /* parameters */
  define input  parameter pUser     as character no-undo.
  define input  parameter pPrivate  as logical   no-undo.
  define input  parameter pEntity   as character no-undo.
  define input  parameter pEntityID as character no-undo.
  define input  parameter pCategory as character no-undo.
  define input  parameter pFile     as character no-undo.
  define input  parameter pFileName as character no-undo.
  define output parameter table for arc-output-document.
  define output parameter pSuccess  as logical   no-undo.
  define output parameter pMsg      as character no-undo.
  
  /* variable */
  define variable tFilename as character no-undo.
  define variable tCopyFile as character no-undo.
  
  /* make sure the file is valid */
  file-info:file-name = pFile.
  if file-info:full-pathname = ?
   then
    do:
      pSuccess = false.
      pMsg = "File " + pFile + " not found".
      return.
    end.
    
   /* extract actual filename from full path */
   tFilename = entry(num-entries(pFile, "\"), pFile, "\").
 
  /* get temp folder path */
  publish "GetSystemParameter" ("TempFolder", OUTPUT tCopyFile). 
  /* fallback to dataRoot if temp folder empty */
  if tCopyFile = ""
   then
    publish "GetSystemParameter" ("dataRoot", OUTPUT tCopyFile).
 
  /* build full target path for copy */
   tCopyFile = tCopyFile + tFilename.
 
  /* copy the file into temp/data folder */
  os-copy value(pFile) value(tCopyFile).
 
  /* use UI filename if provided, else use original */
  if pFileName = "" or pFileName = ?
   then 
    tFilename =  entry(num-entries(pFile, "\"), pFile, "\").
  else
   tFilename = pFileName.

  /* the URL */
  tURL = getURL("Upload").
  tURL = replace(tURL, "&1", encodeUrl(tFilename)).
  tURL = replace(tURL, "&2", encodeUrl(pUser)).
  tURL = replace(tURL, "&3", encodeUrl((if pPrivate then "true" else "false"))).
  tURL = replace(tURL, "&4", encodeUrl(pEntity)).
  tURL = replace(tURL, "&5", encodeUrl(pEntityID)).
  tURL = replace(tURL, "&6", encodeUrl(pCategory)).

  /* header */
  tHeader = "Accept:application/xml".
  if tAuth > ""
   then tHeader = tHeader + "," + tAuth.
  
      
  /* call the ARC */
  run util/httppost.p 
     (input  "ARCRepoFileUpload",
      input  tURL,
      input  tHeader,
      input  "application/octet-stream",
      input  tCopyFile,
      output pSuccess,
      output pMsg,
      output tResponseFile).

  if pMsg > ""
   then return.
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UploadPAR Include 
PROCEDURE UploadPAR :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  /* parameters */
  define input  parameter pUID      as character no-undo.
  define input  parameter pPass     as character no-undo.
  define input  parameter pParentID as character no-undo.
  define input  parameter pFile     as character no-undo.
  define input  parameter pFileName as character no-undo.
  define output parameter pSuccess  as logical   no-undo.
  define output parameter pMsg      as character no-undo.
  
  /* variable */
  define variable tFilename as character no-undo.
  define variable tCopyFile as character no-undo.
  define variable tMemptr   as memptr no-undo.
  
  /* make sure the file is valid */
  file-info:file-name = pFile.
  if file-info:full-pathname = ?
   then
    do:
      pSuccess = false.
      pMsg = "File " + pFile + " not found".
      return.
    end.
    
  /* get the filename */
  tFilename = entry(num-entries(pFile, "\"), pFile, "\").

  /* copy the file */
  publish "GetTempDir" (output tCopyFile).
  if tCopyFile = ""
   then publish "GetSystemParameter" ("dataRoot", OUTPUT tCopyFile).
  tCopyFile = tCopyFile + tFilename.
  os-copy value(pFile) value(tCopyFile).

  /* the URL */
  tURL = getURL("PAR").

  /* header */
  output to "authentication.txt".
  put unformatted pUID + ":" + pPass skip.
  output close.
  
  copy-lob file "authentication.txt" to tMemptr.
  os-delete "authentication.txt".
  tHeader = "Authorization: Basic " + base64-encode(tMemptr).
      
  /* call the ARC */
  run util/httppost.p 
     (input  "ARCRepoPAR",
      input  tURL,
      input  tHeader,
      input  "multipart/form-data",
      input  "field=attachment,system=Ticketing,parentId=" + pParentID + ",=@" + tCopyFile + ";filename=" + pFileName,
      output pSuccess,
      output pMsg,
      output tResponseFile).

  if pMsg > ""
   then return.
  
  /* parse the XML */
  empty temp-table arc-output-document.
  pSuccess = parseXML(output pMsg).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getAuthorization Include 
FUNCTION getAuthorization RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable tAuth as character no-undo.

  tAuth = "".
  publish "GetAuthorization" (output tAuth).
  if tAuth > ""
   then tAuth = "Authorization: Basic " + tAuth.
  RETURN tAuth.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getURL Include 
FUNCTION getURL RETURNS CHARACTER
  ( input pRepository as character ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/
  define variable tURL as character no-undo.

  /* the URL */
  tURL = "".
  publish "GetARCRepositoryURL" (pRepository, output tURL).
  if tURL = ""
   then publish "GetSystemParameter" ("ARCRepository" + pRepository, output tURL).
  RETURN tURL.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

