&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*---------------------------------------------------------------------
@name sf-procedures.i
@description Procedures for getting the Repository data

@author John Oliver
@version 1.0
@created 10/20/2016
@notes 
---------------------------------------------------------------------*/

/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
{lib/repository-def.i}

/* Parse JSON */
define variable tResponseFile as character no-undo.
{lib/jsonparse.i &exclude-StartElement=true &jsonfile=tResponseFile &root=Repository &has-namespace=true}
{lib/add-delimiter.i}

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

publish "LoadRepositoryFields". /* client-side publish */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CopyRepositoryItem Include 
PROCEDURE CopyRepositoryItem :
/*------------------------------------------------------------------------------
@description Copies an item into a new folder
------------------------------------------------------------------------------*/
  define input  parameter pFromFolderPath as character no-undo.
  define input  parameter pToFolderPath   as character no-undo.
  define output parameter pSuccess        as logical   no-undo initial false.
  define output parameter pMsg            as character no-undo.
  
  define variable pFromFolderID as character no-undo.
  define variable pToFolderID   as character no-undo.

  /* get the item id for the from item */
  run GetRepositoryItemID (pFromFolderPath, output pFromFolderID, output pSuccess, output pMsg).
  if not pSuccess or pFromFolderID = ""
   then return.
   
  /* get the item info for the to folder */
  empty temp-table repository-item.
  run GetRepositoryItem (pToFolderPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* verify that the item is a folder */
  for first repository-item no-lock:
    if repository-item.filetype = "File"
     then
      do:
        pSuccess = false.
        pMsg = "Cannot copy into a file".
        return.
      end.
     else pToFolderID = repository-item.identifier.
  end.
  
  /* check if the URL is valid */
  tURL =  getURL("RepositoryItemCopyService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemCopyService URL is not found".
      return.
    end.
    
  /* build the URL */
  tURL = replace(tURL, "&1", pFromFolderID).
  tURL = replace(tURL, "&2", pToFolderID).
  
  /* create a blank request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryCopyItem7", tPostFile).

  /* run as POST */
  run HTTPPost ("RepositoryCopyItem", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeleteRepositoryItem Include 
PROCEDURE DeleteRepositoryItem :
/*------------------------------------------------------------------------------
@description Deletes the item
------------------------------------------------------------------------------*/
  define input  parameter pPath  as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  define variable tItemID as character no-undo.
  
  /* get the authorization token */
  run GetRepositoryItemID (pPath, output tItemID, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* check if URL is found */
  tURL =  getURL("RepositoryItemDeleteService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemDeleteService URL is not found".
      return.
    end.
    
  /* build the URL */
  tURL = replace(tURL, "&1", tItemID).
  
  /* delete the item */
  run HTTPDelete ("RepositoryDeleteItem", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DownloadRepositoryFile Include 
PROCEDURE DownloadRepositoryFile :
/*------------------------------------------------------------------------------
@description Download a file
------------------------------------------------------------------------------*/
  define input  parameter pServerPath as character no-undo.
  define input  parameter pLocalFile  as character no-undo.
  define output parameter pSuccess    as logical no-undo initial false.
  define output parameter pMsg        as character no-undo.

  /* get the item information */
  empty temp-table repository-item.
  run GetRepositoryItem (pServerPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
  
  /* make sure the item is a file */
  if can-find(first repository-item where filetype = "Folder")
   then
    do:
      pSuccess = false.
      pMsg = "Cannot download a folder".
      return.
    end.
   
  /* make sure the URL is valid */
  tURL =  getURL("RepositoryDownloadService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryDownloadService URL is not found".
      return.
    end.

  /* build the URL */
  for first repository-item no-lock:
    tURL = substitute(tURL, repository-item.identifier).
  end.

  /* get the download link */
  run HTTPGet ("RepositoryFileDownload", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isFile = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isFile = false.
   
  /* call the download link */
  if pSuccess
   then
    do:
      run HTTPGet ("RepositoryFileDownload2", tDownloadLink, "", output pSuccess, output pMsg, output tResponseFile).
      copy-lob file tResponseFile to file pLocalFile.   
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE EndElement Include 
PROCEDURE EndElement :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define input parameter pNamespace   as character no-undo.
  define input parameter pLocalName   as character no-undo.
  define input parameter pElementName as character no-undo.
  
  if isAuth /* Authorization */
   then
    case pLocalName:
     /* for an error */
     when "error" then parseStatus = false.
     when "error_description" then parseMsg = curElementValue.
     /* normal return */
     when "access_token" then {&repo-token} = curElementValue.
    end case.
    
  if isItemParent or isItem /* Item */
   then
    do:
      if isItemParent
       then
        case pLocalName:
         when "Id" then tItemParentID = curElementValue.
         when "Parent" then isItemParent = false.
        end case.
       else
        case pLocalName:
         /* for an error */
         when "code" then parseStatus = false.
         when "value" or
         when "Repository" then
          if not parseStatus
           then parseMsg = curElementValue.
           else
            /* create the document */
            do:
              if can-find(first repository-item where identifier = tItemID)
               then return.
              
              if tItemSize = ? 
               then tItemSize = 0.
              if tItemSize >= 1000000000 
               then assign
                      std-de = round(tItemSize / 1000000000, 1)
                      std-ch = " GB"
                      .
               else
              if tItemSize >= 1000000
               then assign
                      std-de = round(tItemSize / 1000000, 1)
                      std-ch = " MB"
                      .
               else assign
                      std-de = round(tItemSize / 1000, 1)
                      std-ch = " KB"
                      .
              if tItemID > ""
               then
                do:
                  create repository-item.
                  repository-item.fileSizeDesc = string(std-de) + std-ch.
                  if tItemPath > ""
                   then
                    if index(tItemPath, tItemName) = 0
                     then repository-item.fullpath = tItemPath + "/" + tItemName.
                     else repository-item.fullpath = tItemPath.
                  assign
                    repository-item.identifier  = tItemID
                    repository-item.type        = tItemType
                    repository-item.filetype    = tItemType
                    repository-item.name        = tItemName
                    repository-item.displayName = tItemDisplayName
                    repository-item.details     = tItemDescription
                    repository-item.createdDate = tItemCreatedDate
                    repository-item.createdBy   = tItemCreatedBy
                    repository-item.fileSize    = tItemSize
                    repository-item.parentID    = tItemParentID
                    repository-item.fileCount   = tItemFileCount
                    .
                  assign
                    tItemID = ""
                    tItemType = ""
                    tItemName = ""
                    tItemDisplayName = ""
                    tItemSize = 0
                    tItemCreatedDate = ""
                    tItemCreatedBy = ""
                    tItemParentID = ""
                    tItemDescription = ""
                    .
                end.
            end.
         /* normal return */
         when "Id" then tItemID = curElementValue.
         when "odata.type" then tItemType = entry(num-entries(curElementValue, "."), curElementValue, ".").
         when "Name" then tItemDisplayName = curElementValue.
         when "FileSizeBytes" then tItemSize = decimal(curElementValue) no-error.
         when "CreatorNameShort" then tItemCreatedBy = curElementValue.
         when "CreationDate" then tItemCreatedDate = curElementValue.
         when "FileName" then tItemName = curElementValue.
         when "Description" then tItemDescription = curElementValue.
         when "FileCount" then tItemFileCount = integer(curElementValue).
        end.
    end.
    
  if isFile
   then
    case pLocalName:
     /* for an error */
     when "code" then parseStatus = false.
     when "value" then parseMsg = curElementValue.
     /* normal return */
     when "DownloadUrl" then tDownloadLink = curElementValue.
     when "ChunkUri" then tUploadLink = curElementValue.
    end case.
    
  if isUser
   then
    case pLocalName:
     /* for an error */
     when "code" then parseStatus = false.
     when "value" then parseMsg = curElementValue.
     /* normal return */
     when "Id" then tUserID = curElementValue.
     when "FullName" then tUserName = curElementValue.
     when "Email" then tUserPrimaryEmail = curElementValue.
     when "Company" then tUserCompany = curElementValue.
     when "IsAdministrator" then tUserAdmin = logical(curElementValue) no-error.
     when "Roles" then tUserEmployee = (tUserEmployee or curElementName = "Employee").
     when "CanResetPassword" then tUserPassword = logical(curElementValue) no-error.
     when "RequireLoginByDefault" then tUserRequireDownloadLogin = logical(curElementValue) no-error.
     when "CanViewMySettings" then tUserCanViewMySettings = logical(curElementValue) no-error.
     when "DateFormat" then  tUserDateFormat = curElementValue.
     /* create the user */
     when "Repository" then
      do:
        create repository-user.
        assign
          repository-user.ID = tUserID
          repository-user.Name = tUserName
          repository-user.primaryEmail = tUserPrimaryEmail
          repository-user.company = tUserCompany
          repository-user.accountEmployee = tUserEmployee
          repository-user.accountAdmin = tUserAdmin
          .
        assign
          tUserID = ""
          tUserName = ""
          tUserPrimaryEmail = ""
          tUserCompany = ""
          tUserEmployee = false
          tUserAdmin = false
          .
      end.
    end case.
    
  if isUserPreference
   then
    case pLocalName:
     /* for an error */
     when "code" then parseStatus = false.
     when "value" then parseMsg = curElementValue.
     /* normal return */
     when "CanResetPassword" then tUserPassword = logical(curElementValue) no-error.
     when "RequireLoginByDefault" then tUserRequireDownloadLogin = logical(curElementValue) no-error.
     when "CanViewMySettings" then tUserCanViewMySettings = logical(curElementValue) no-error.
     when "DateFormat" then  tUserDateFormat = curElementValue.
     /* create the user */
     when "Repository" then
      for first repository-user no-lock:
        assign
          repository-user.canResetPassword = tUserPassword
          repository-user.requireDownloadLogin = tUserRequireDownloadLogin
          repository-user.canViewMySettings = tUserCanViewMySettings
          repository-user.dateFormat = tUserDateFormat
          .
        assign
          tUserPassword = false
          tUserRequireDownloadLogin = false
          tUserCanViewMySettings = false
          tUserDateFormat = ""
          .
      end.
    end case.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryFolder Include 
PROCEDURE GetRepositoryFolder :
/*------------------------------------------------------------------------------
@description Gets the contents of a folder
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define output parameter table for repository-item.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  /* get folder information */
  empty temp-table repository-item.
  run GetRepositoryItem (pPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* check if the URL is invalid */
  tURL =  getURL("RepositoryItemChildrenService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemChildrenService URL is not found".
      return.
    end.

  /* build the URL */
  for first repository-item no-lock:
    if repository-item.type = "File"
     then tURL = substitute(tURL, repository-item.parentID).
     else tURL = substitute(tURL, repository-item.identifier).
  end.

  /* build the contents of the folder */
  empty temp-table repository-item.
  run HTTPGet ("RepositoryGetFolder", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the data */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryItem Include 
PROCEDURE GetRepositoryItem :
/*------------------------------------------------------------------------------
@description Gets the item info 
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define output parameter table for repository-item.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  /* get the authorization token */
  run GetRepositoryToken ("", "", output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* check if the URL is valid */
  tURL =  getURL("RepositoryItemByPathService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemByPathService URL is not found".
      return.
    end.
    
  /* get the root path */
  std-ch = "".
  publish "GetRepositoryRoot" (output std-ch).
  if std-ch = ""
   then publish "GetSystemParameter" ("RepositoryRootFolder", output std-ch).
   
  /* see if the path already has the root */
  if index(pPath, std-ch) = 0
   then tItemPath = std-ch + pPath.
   else tItemPath = pPath.

  /* build the URL */
  tURL = substitute(tURL, encodeUrl(tItemPath)).

  /* get the item info */
  empty temp-table repository-item.
  run HTTPGet ("RepositoryItemInfo", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryItemID Include 
PROCEDURE GetRepositoryItemID :
/*------------------------------------------------------------------------------
@description Gets the item ID 
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define output parameter pItemID  as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  /* get the item info */
  empty temp-table repository-item.
  run GetRepositoryItem (pPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* return the item identifier */
  for first repository-item no-lock:
    pItemID = repository-item.identifier.
  end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryItemLink Include 
PROCEDURE GetRepositoryItemLink :
/*------------------------------------------------------------------------------
@description Gets the item link 
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define output parameter pLink    as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  std-ch = "".
  run GetRepositoryItemID (pPath, output std-ch, output pSuccess, output pMsg).
  if not pSuccess or std-ch = ""
   then return.
  
  pLink =  getURL("RepositoryFolderLink").
  if pLink = "" 
   then
    do:
      pSuccess = false.
      pMsg = "Could not retrieve the folder link".
      return.
    end.

  pLink = substitute(pLink, std-ch).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryToken Include 
PROCEDURE GetRepositoryToken :
/*------------------------------------------------------------------------------
@description Get the auth token for all subsequent Repository calls
------------------------------------------------------------------------------*/
  define input  parameter pUserID  as character no-undo initial "".
  define input  parameter pUserPW  as character no-undo initial "".
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.
  
  /* the following is a client side publish to "refresh" the token periodically */
  publish "GetRepositoryToken" (output {&repo-token}).
  
  /* if there is already a token, just return */
  if {&repo-token} > ""
   then
    do:
      pSuccess = true.
      return.
    end.

  if pUserID = ""
   then
    do:
      pSuccess = false.
      pMsg = "No username passed in for GetRepositoryToken".
      return.
    end.
    
  if pUserPW = ""
   then
    do:
      pSuccess = false.
      pMsg = "No password passed in for GetRepositoryToken".
      return.
    end.
   
  if pSuccess
   then return.

  define variable tClientID as character no-undo.
  define variable tSecret   as character no-undo.

  /* get the URL */
  tURL =  getURL("RepositoryAuthService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryAuthService URL is not found".
      return.
    end.

  /* build the query */
  publish "GetRepositoryClientID" (output tClientID). /* Client */
  publish "GetRepositorySecret" (output tSecret).     /* Client */
  publish "GetSystemParameter" ("RepositoryClientID", output tClientID). /* Server */
  publish "GetSystemParameter" ("RepositorySecret", output tSecret).     /* Server */
  tURL = replace(tURL, "&1", encodeUrl(tClientID)).
  tURL = replace(tURL, "&2", encodeUrl(tSecret)).
  tURL = replace(tURL, "&3", encodeUrl(pUserID)).
  tURL = replace(tURL, "&4", encodeUrl(pUserPW)).

  /* get the data */
  run HTTPGet ("RepositoryAuthToken", tURL, "", output pSuccess, output pMsg, output tResponseFile).
  /* parse the JSON */
  isAuth = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isAuth = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryUser Include 
PROCEDURE GetRepositoryUser :
/*------------------------------------------------------------------------------
@description Get a user 
------------------------------------------------------------------------------*/
  define input  parameter pID      as character no-undo.
  define output parameter table for repository-user.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  /* authorize user */
  run GetRepositoryToken ("", "", output pSuccess, output pMsg).
  if not pSuccess
   then return.
  
  /* get the URL for the user */
  tURL =  getURL("RepositoryUserService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserService URL is not found".
      return.
    end.

  /* build URL */
  tURL = substitute(tURL, encodeUrl(pID)).

  /* get the user */
  run HTTPGet ("RepositoryUser", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isUser = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isUser = false.
  
  if not pSuccess
   then return.
  
  /* get the URL for the user preferences */
  tURL =  "".
  publish "GetRepositoryURL" ("RepositoryUserPreferenceService", output tURL).
  if tURL = ""
   then publish "GetSystemParameter" ("RepositoryUserPreferenceService", output tURL).
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserPreferenceService URL is not found".
      return.
    end.

  /* build the URL */
  for first repository-user no-lock:
    tURL = substitute(tURL, repository-user.ID).
  end.

  /* get the preferences */
  run HTTPGet ("RepositoryUserPreference", tURL, "Authorization: Bearer " + {&repo-token}, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isUserPreference = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isUserPreference = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GetRepositoryUserID Include 
PROCEDURE GetRepositoryUserID :
/*------------------------------------------------------------------------------
@description Gets the user ID 
------------------------------------------------------------------------------*/
  define input  parameter pUser    as character no-undo.
  define output parameter pUserID  as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.

  /* get the item info */
  empty temp-table repository-user.
  run GetRepositoryUser (pUser, output table repository-user, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* return the item identifier */
  for first repository-user no-lock:
    pUserID = repository-user.ID.
  end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GrantRepositoryUser Include 
PROCEDURE GrantRepositoryUser :
/*------------------------------------------------------------------------------
@description Grant a user access to a particular folder/file
------------------------------------------------------------------------------*/
  define input  parameter pPath        as character no-undo.
  define input  parameter pUser        as character no-undo.
        define input  parameter pCanUpload   as logical no-undo.
        define input  parameter pCanDownload as logical no-undo.
        define input  parameter pCanDelete   as logical no-undo.
        define input  parameter pCanAdmin    as logical no-undo.
  define output parameter pSuccess     as logical   no-undo initial false.
  define output parameter pMsg         as character no-undo.
  
  define variable tUserID  as character no-undo.
  define variable tItemID  as character no-undo.
  define variable tUserURL as character no-undo.

  /* get the user */
  run GetRepositoryUserID (pUser, output tUserID, output pSuccess, output pMsg).
  if not pSuccess or tUserID = ""
   then return.
   
  /* get the path ID */
  run GetRepositoryItemID (pPath, output tItemID, output pSuccess, output pMsg).
  if not pSuccess or tItemID = ""
   then return.
   
  /* get the URL for the user grant */
  tURL =  getURL("RepositoryUserGrantService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserGrantService URL is not found".
      return.
    end.
   
  /* build the URL */
  tURL = substitute(tURL, tItemID).
  
  /* get the user URL */
  tUserURL =  getURL("RepositoryUserBaseService").
  if tUserURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserBaseService URL is not found".
      return.
    end.
    
  /* create the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Principal~": ~{~"url~":~"" + substitute(tUserURL, tUserID) + "~"~}," skip.
  put unformatted "  ~"CanUpload~": " + (if pCanUpload then "true" else "false") + "," skip.
  put unformatted "  ~"CanDownload~": " + (if pCanDownload then "true" else "false") + "," skip.
  put unformatted "  ~"CanView~": true," skip.
  put unformatted "  ~"CanDelete~": " + (if pCanDelete then "true" else "false") + "," skip.
  put unformatted "  ~"CanManagePermissions~": " + (if pCanAdmin then "true" else "false") skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryGrantUser7", tPostFile).
  
  /* create the user */
  empty temp-table repository-user.
  run HTTPPost ("RepositoryGrantUser", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isUser = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isUser = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ModifyRepositoryItem Include 
PROCEDURE ModifyRepositoryItem :
/*------------------------------------------------------------------------------
@description Edits the item
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define input  parameter pName    as character no-undo.
  define input  parameter pNotes   as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.
  
  define variable tItemID  as character no-undo.

  /* get the path ID */
  run GetRepositoryItemID (pPath, output tItemID, output pSuccess, output pMsg).
  if not pSuccess or tItemID = ""
   then return.
   
  /* get the URL */
  tURL =  getURL("RepositoryItemService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemService URL is not found".
      return.
    end.

  /* build the URL */
  tURL = substitute(tURL, tItemID).
  
  /* build the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  if pName > ""
   then
    do:
      put unformatted "  ~"Name~": ~"" + pName + "~"," skip.
      put unformatted "  ~"Filename~": ~"" + pName + "~"," skip.
    end.
  put unformatted "  ~"Description~": ~"" + pNotes + "~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryModifyItem7", tPostFile).

  /* modify the item */
  run HTTPPatch ("RepositoryModifyItem", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MoveRepositoryItem Include 
PROCEDURE MoveRepositoryItem :
/*------------------------------------------------------------------------------
@description Moves the item
------------------------------------------------------------------------------*/
  define input  parameter pPath    as character no-undo.
  define input  parameter pNewPath as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.
  
  define variable tItemID  as character no-undo.

  /* get the path ID */
  run GetRepositoryItemID (pPath, output tItemID, output pSuccess, output pMsg).
  if not pSuccess or tItemID = ""
   then return.
  
  /* check the new folder path */
  if pNewPath = ""
   then
    do:
      pSuccess = false.
      pMsg = "The new folder path is missing".
      return.
    end.
   
  /* get the item into for the new folder path */
  empty temp-table repository-item.
  run GetRepositoryItem (pNewPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
  
  /* make sure the new path is not a file */
  if can-find(first repository-item where filetype = "File")
   then
    do:
      pSuccess = false.
      pMsg = "Cannot put an item inside a file".
      return.
    end.
   
  /* get the utl */
  tURL =  getURL("RepositoryItemService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryItemService URL is not found".
      return.
    end.

  /* build the URL */
  tURL = substitute(tURL, tItemID).
  
  /* create the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Parent~": ~{" skip.
  for first repository-item no-lock:
    put unformatted "    ~"Id~": ~"" + repository-item.identifier + "~"" skip.
  end.
  put unformatted "  ~}" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryMoveItem7", tPostFile).

  /* move the item */
  empty temp-table repository-item.
  run HTTPPatch ("RepositoryMoveItem", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NewRepositoryFolder Include 
PROCEDURE NewRepositoryFolder :
/*------------------------------------------------------------------------------
@description Creates a folder
------------------------------------------------------------------------------*/
  define input  parameter pFolderPath as character no-undo.
  define output parameter pSuccess    as logical   no-undo initial false.
  define output parameter pMsg        as character no-undo.
  
  define variable tFolderName as character no-undo.
  define variable tFolderID   as character no-undo.
  define variable tParentPath as character no-undo.
  define variable tParentID   as character no-undo.
  define variable tFolderPath as character no-undo.
  
  if pFolderPath = ""
   then
    do:
      pMsg = "Folder path is missing".
      return.
    end.
  
  /* see if the folder exists */
  run GetRepositoryItemID (pFolderPath, output tFolderID, output pSuccess, output pMsg).
  if pSuccess or tFolderID > ""
   then
    do:
      pSuccess = true.
      return.
    end.

  /* make sure the folder path does not contain a / as the last character */
  if substring(pFolderPath, length(pFolderPath), 1) = "/" 
   then pFolderPath = substring(pFolderPath, 1, length(pFolderPath) - 1).
   
  tFolderPath = pFolderPath.
   
  /* the name of the new folder and the parent path */
  tFolderName = substring(pFolderPath, r-index(pFolderPath, "/") + 1).
  tParentPath = substring(pFolderPath, 1, r-index(pFolderPath, "/")).
  
  /* get the ID of the parent folder */
  run GetRepositoryItemID (tParentPath, output tParentID, output pSuccess, output pMsg).
  if tParentID = ""
   then
    do:
      run NewRepositoryFolder (tParentPath, output pSuccess, output pMsg).
      if pSuccess
       then run GetRepositoryItemID (tParentPath, output tParentID, output pSuccess, output pMsg).
    end.
    
  /* get the URL */
  tURL =  getURL("RepositoryFolderCreateService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryFolderCreateService URL is not found".
      return.
    end.

  /* build the URL */
  tURL = substitute(tURL, tParentID).
  
  /* build the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Name~": ~"" + tFolderName + "~"," skip.
  put unformatted "  ~"ExpirationDate: ~": ~"9999-12-31T23:59:59.9999999Z~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryNewFolder7", tPostFile).
  
  /* create the folder */
  run HTTPPost ("RepositoryNewFolder", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isItem = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isItem = false.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE NewRepositoryUser Include 
PROCEDURE NewRepositoryUser :
/*------------------------------------------------------------------------------
@description Create a user 
------------------------------------------------------------------------------*/
  define input  parameter pFirstName         as character no-undo.
  define input  parameter pLastName          as character no-undo.
  define input  parameter pEmail             as character no-undo.
  define input  parameter pIsEmployee        as logical   no-undo.
  define input  parameter pCompany           as character no-undo.
  define input  parameter pIsAdmin           as logical   no-undo.
  define input  parameter pNewFolders        as logical   no-undo.
  define input  parameter pUseFileBox        as logical   no-undo.
  define input  parameter pManageUsers       as logical   no-undo.
  define input  parameter pPassword          as character no-undo.
  define input  parameter pNotify            as logical   no-undo.
  define input  parameter pCanResetPassword  as logical   no-undo.
  define input  parameter pCanViewMySettings as logical   no-undo.
  define output parameter table for repository-user.
  define output parameter pSuccess           as logical   no-undo initial false.
  define output parameter pMsg               as character no-undo.
  
  define variable tUserID as character no-undo.

  /* see if the user exists */
  run GetRepositoryUserID (pEmail, output tUserID, output pSuccess, output pMsg).
  if pSuccess or tUserID > ""
   then
    do:
      pSuccess = true.
      return.
    end.
   
  /* get correct URL */
  if pIsEmployee
   then tURL =  getURL("RepositoryUserCreateEmployeeService").
   else tURL =  getURL("RepositoryUserCreateClientService").
  
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryNewUserService URL is not found".
      return.
    end.
   
  /* build the URL */
  tURL = substitute(tURL, (if pNotify then "true" else "false")).
    
  /* create the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Email~": ~"" + pEmail + "~"," skip.
  put unformatted "  ~"FirstName~": ~"" + pFirstName + "~"," skip.
  put unformatted "  ~"LastName~": ~"" + pLastName + "~"," skip.
  put unformatted "  ~"Company~": ~"" + pCompany + "~"," skip.
  put unformatted "  ~"Password~": ~"" + pPassword + "~"," skip.
  if pIsEmployee
   then
    do:
      put unformatted "  ~"IsAdministrator~": " + (if pIsAdmin then "true" else "false") + "," skip.
      put unformatted "  ~"CanNewFolders~": " + (if pNewFolders then "true" else "false") + "," skip.
      put unformatted "  ~"CanUseFileBox~": " + (if pUseFileBox then "true" else "false") + "," skip.
      put unformatted "  ~"CanManageUsers~": " + (if pManageUsers then "true" else "false") + "," skip.
    end.
  put unformatted "  ~"Preferences~": ~{" skip.
  put unformatted "    ~"CanResetPassword~": " + (if pCanResetPassword then "true" else "false") + "," skip.
  put unformatted "    ~"CanViewMySettings~": " + (if pCanViewMySettings then "true" else "false") skip.
  put unformatted "  ~}" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryNewUser7", tPostFile).
  
  /* create the user */
  empty temp-table repository-user.
  run HTTPPost ("RepositoryNewUser", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isUser = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isUser = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RequestRepositoryDownload Include 
PROCEDURE RequestRepositoryDownload :
/*------------------------------------------------------------------------------
@description Sends an email to a user to download a file
------------------------------------------------------------------------------*/
  define input  parameter pFilePath         as character no-undo.
  define input  parameter pTo               as character no-undo.
  define input  parameter pSubject          as character no-undo.
  define input  parameter pBody             as character no-undo.
  define input  parameter pCCSender         as logical   no-undo.
  define input  parameter pRequireLogin     as logical   no-undo.
  define input  parameter pAnonLink         as logical   no-undo.
  define input  parameter pExpirationDays   as integer   no-undo.
  define input  parameter pNotifyOnDownload as logical   no-undo.
  define input  parameter pIsViewOnly       as logical   no-undo.
  define input  parameter pMaxDownloads     as integer   no-undo.
  define input  parameter pUseStreamIDs     as logical   no-undo.
  define output parameter pSuccess          as logical   no-undo initial false.
  define output parameter pMsg              as character no-undo.
  
  define variable tFileID as character no-undo.
  
  /* if the file ID is provided, use that */
  run GetRepositoryItemID (pFilePath, output tFileID, output pSuccess, output pMsg).
  if not pSuccess
   then return.
      
  tURL =  getURL("RepositorySendService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositorySendService URL is not found".
      return.
    end.
    
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Items~": [~"" + tFileID + "~"]," skip.
  put unformatted "  ~"Emails~": [".
  do std-in = 1 to num-entries(pTo, ";"):
    put unformatted "~"" + entry(std-in, pTo, ";") + "~"".
    if std-in < num-entries(pTo, ";")
     then put unformatted ",".
  end.
  put unformatted "]," skip.
  put unformatted "  ~"Subject~": ~"" + (if pSubject = "" or pSubject = ? then "Repository Folder/File Download" else pSubject) + "~"," skip.
  put unformatted "  ~"Body~": ~"" + pBody + "~"," skip.
  put unformatted "  ~"CcSender~": " + (if pCCSender then "true" else "false") + "," skip.
  put unformatted "  ~"NotifyOnDownload~": " + (if pNotifyOnDownload then "true" else "false") + "," skip.
  put unformatted "  ~"SendAnon~": " + (if pAnonLink then "true" else "false") + "," skip.
  put unformatted "  ~"IsViewOnly~": " + (if pIsViewOnly then "true" else "false") + "," skip.
  put unformatted "  ~"UsesStreamIDs~": " + (if pUseStreamIDs then "true" else "false") + "," skip.
  put unformatted "  ~"RequireLogin~": " + (if pRequireLogin then "true" else "false") + "," skip.
  put unformatted "  ~"MaxDownloads~": ~"" + (if pMaxDownloads > 0 then string(pMaxDownloads) else "-1") + "~"," skip.
  put unformatted "  ~"ExpirationDays~": ~"" + (if pExpirationDays > 0 then string(pExpirationDays) else "30") + "~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryRequestDownload7", tPostFile).
  
  empty temp-table repository-item.
  run HTTPPost ("RepositoryRequestDownload", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isFile = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isFile = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RequestRepositoryUpload Include 
PROCEDURE RequestRepositoryUpload :
/*------------------------------------------------------------------------------
@description Sends an email to a user to request an upload
------------------------------------------------------------------------------*/
  define input  parameter pFolderPath     as character no-undo.
  define input  parameter pTo             as character no-undo.
  define input  parameter pSubject        as character no-undo.
  define input  parameter pBody           as character no-undo.
  define input  parameter pCCSender       as logical   no-undo.
  define input  parameter pRequireLogin   as logical   no-undo.
  define input  parameter pExpirationDays as integer   no-undo.
  define input  parameter pNotifyOnUpload as logical   no-undo.
  define output parameter pSuccess        as logical   no-undo initial false.
  define output parameter pMsg            as character no-undo.
  
  /* verify the folder is not a file */
  empty temp-table repository-item.
  run GetRepositoryItem (pFolderPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  if can-find(first repository-item where filetype = "File")
   then
    do:
      pSuccess = false.
      pMsg = "The path is a file and not a folder".
      return.
    end.
   
  tURL =  getURL("RepositoryRequestService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryRequestService URL is not found".
      return.
    end.
    
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  for first repository-item no-lock:
    put unformatted "  ~"FolderId~": ~"" + repository-item.identifier + "~"," skip.
  end.
  put unformatted "  ~"Emails~": [".
  do std-in = 1 to num-entries(pTo, ";"):
    put unformatted "~"" + entry(std-in, pTo, ";") + "~"".
  end.
  put unformatted "]," skip.
  put unformatted "  ~"Subject~": ~"" + (if pSubject = "" or pSubject = ? then "Repository Folder Upload" else pSubject) + "~"," skip.
  put unformatted "  ~"Body~": ~"" + pBody + "~"," skip.
  put unformatted "  ~"CcSender~": " + (if pCCSender then "true" else "false") + "," skip.
  put unformatted "  ~"NotifyOnUpload~": " + (if pNotifyOnUpload then "true" else "false") + "," skip.
  put unformatted "  ~"RequireLogin~": " + (if pRequireLogin then "true" else "false") + "," skip.
  put unformatted "  ~"ExpirationDays~": ~"" + (if pExpirationDays > 0 then string(pExpirationDays) else "30") + "~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryRequestUpload7", tPostFile).
  
  empty temp-table repository-item.
  run HTTPPost ("RepositoryRequestUpload", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isFile = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isFile = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ResetRepositoryPassword Include 
PROCEDURE ResetRepositoryPassword :
/*------------------------------------------------------------------------------
@description Resets a user password
------------------------------------------------------------------------------*/
  define input  parameter pUser    as character no-undo.
  define input  parameter pUserPW  as character no-undo.
  define input  parameter pNewPw   as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.
  
  define variable tUserID as character no-undo.

  /* authorize user */
  run GetRepositoryUserID (pUser, output tUserID, output pSuccess, output pMsg).
  if not pSuccess
   then return.
  
  /* get the correct URL */
  tURL =  getURL("RepositoryUserPasswordService").
  if tURL = ""
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserPasswordService URL is not found".
      return.
    end.
    
  /* build the URL */
  tURL = substitute(tURL, tUserID).
  
  /* build the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"OldPassword~": ~"" + pUserPW + "~"," skip.
  put unformatted "  ~"NewPassword~": ~"" + pNewPw + "~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryResetPassword7", tPostFile).
  
  empty temp-table repository-user.
  run HTTPPost ("RepositoryResetPassword", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isUser = true.
  file-info:file-name = tResponseFile.
  if not pSuccess and file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isUser = false.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SendRepositoryWelcome Include 
PROCEDURE SendRepositoryWelcome :
/*------------------------------------------------------------------------------
@description Sends a user a welcome notification
------------------------------------------------------------------------------*/
  define input  parameter pUser    as character no-undo.
  define input  parameter pBody    as character no-undo.
  define output parameter pSuccess as logical   no-undo initial false.
  define output parameter pMsg     as character no-undo.
  
  define variable tUserID as character no-undo.
  
  /* get the user */
  run GetRepositoryUserID (pUser, output tUserID, output pSuccess, output pMsg).
  if not pSuccess
   then return.
   
  /* get the url */
  tURL =  getURL("RepositoryUserWelcomeService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUserWelcomeService URL is not found".
      return.
    end.

  /* build the url */
  tURL = substitute(tURL, tUserID).

  /* build the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"CustomMessage~": ~"" + pBody + "~"~"" skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositorySendWelcome7", tPostFile).
  
  /* send the welcome */
  run HTTPPost ("RepositorySendWelcome", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StartElement Include 
PROCEDURE StartElement :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  {lib/jsonstartelement.i}
  
  if isItem and (qName = "value" or qName = "Repository")
   then
    assign
      tItemID = ""
      tItemType = ""
      tItemName = ""
      tItemDisplayName = ""
      tItemSize = 0
      tItemCreatedDate = ""
      tItemCreatedBy = ""
      tItemParentID = ""
      tItemDescription = ""
      .
      
  if isItem and qName = "Parent"
   then isItemParent = true.
      
  if isUser and qName = "Repository"
   then
    assign
      tUserID = ""
      tUserName = ""
      tUserPrimaryEmail = ""
      tUserCompany = ""
      tUserEmployee = false
      tUserAdmin = false
      tUserPassword = false
      tUserRequireDownloadLogin = false
      tUserCanViewMySettings = false
      tUserDateFormat = ""
      .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UploadRepositoryFile Include 
PROCEDURE UploadRepositoryFile :
/*------------------------------------------------------------------------------
@description Upload a file
------------------------------------------------------------------------------*/
  define input  parameter pLocalFile  as character no-undo.
  define input  parameter pServerPath as character no-undo.
  define output parameter pSuccess    as logical   no-undo initial false.
  define output parameter pMsg        as character no-undo.
  
  define variable tFileName as character no-undo.
  define variable tLogFile  as character no-undo.
  define variable tool      as character no-undo.
  define variable cmd       as character no-undo.
  
  /* get the item information */
  empty temp-table repository-item.
  run GetRepositoryItem (pServerPath, output table repository-item, output pSuccess, output pMsg).
  if not pSuccess
   then return.
  
  /* check the file */
  file-info:file-name = pLocalFile.
  if file-info:full-pathname = ?
   then
    do:
      pMsg = "Local file not found".
      return.
    end.
   
  /* make sure the URL is valid */
  tURL =  getURL("RepositoryUploadService").
  if tURL = "" 
   then
    do:
      pSuccess = false.
      pMsg = "RepositoryUploadService URL is not found".
      return.
    end.

  /* build the URL */
  for first repository-item no-lock:
    tURL = substitute(tURL, repository-item.identifier).
  end.
  
  /* build the request */
  tPostFile = replace(guid, "-", "").
  output to value(tPostFile).
  put unformatted "~{" skip.
  put unformatted "  ~"Method~": ~"standard~"," skip.
  put unformatted "  ~"Raw~": ~"true~"," skip.
  put unformatted "  ~"FileName~": ~"" + entry(num-entries(file-info:file-name, "\"), file-info:file-name, "\") + "~"," skip.
  put unformatted "  ~"FileSize~": ~"" + string(file-info:file-size) + "~"," skip.
  put unformatted "~}" skip.
  output close.
  publish "AddTempFile" ("RepositoryFileUpload7", tPostFile).

  /* get the upload link */
  run HTTPPost ("RepositoryFileUpload", tURL, "Authorization: Bearer " + {&repo-token}, "application/json", tPostFile, output pSuccess, output pMsg, output tResponseFile).
  
  /* parse the json */
  isFile = true.
  file-info:file-name = tResponseFile.
  if file-info:full-pathname <> ?
   then pSuccess = parseJson(output pMsg).
  isFile = false.
   
  /* call the upload link */
  if pSuccess
   then
    do:
      run util/httppostcurl.p (input  "RepositoryFileUpload2",
                               input  tUploadLink, 
                               input  "",
                               input  "application/octet-stream",
                               input  pLocalFile,
                               output pSuccess,
                               output pMsg,
                               output tResponseFile).
    end.
    
  assign
    pServerPath = right-trim(pServerPath, "~\")
    pServerPath = right-trim(pServerPath, "~/")
    pServerPath = pServerPath + "/"
    .
    
  run GetRepositoryItemID (pServerPath + tFileName, output std-ch, output pSuccess, output pMsg).
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

