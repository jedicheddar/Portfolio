&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD BuildTable Include 
FUNCTION BuildTable RETURNS handle
  ( INPUT pTable AS CHARACTER,
    INPUT hTable AS HANDLE,
    INPUT hField AS HANDLE )  FORWARD.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION BuildTable Include 
FUNCTION BuildTable RETURNS handle
  ( INPUT pTable AS CHARACTER,
    INPUT hTable AS HANDLE,
    INPUT hField AS HANDLE ) :
/*------------------------------------------------------------------------------
@description Rebuilds the dynamic result table
------------------------------------------------------------------------------*/
  define variable iCol as integer no-undo.
  define variable hQuery as handle no-undo.
  define variable hBuffer as handle no-undo.
  define variable columnName as character no-undo.
  define variable dataType as character no-undo.
  define variable columnFormat as character no-undo.

  iCol = 0.
  /* make sure the dynamic temp table is available */
  if valid-handle(hTable) and hTable:type = "temp-table"
   then
    do:
      if hTable:prepared
       then
        do:
          hTable:default-buffer-handle:empty-temp-table().
          hTable:clear().
        end.

      /* validate that the field list is available */
      if valid-handle(hField) and hField:type = "temp-table"
       then hBuffer = hField:DEFAULT-BUFFER-HANDLE.
       else return ?.

      /* query the table */
      create query hQuery.
      hQuery:set-buffers(hBuffer).
      hQuery:query-prepare("for each " + hBuffer:table + " where entityName='" + pTable + "'").
      hQuery:query-open().
      hQuery:get-first().
      repeat while not hQuery:query-off-end:
        assign
          iCol = iCol + 1
          columnName = hBuffer:buffer-field("columnBuffer"):buffer-value()
          dataType = hBuffer:buffer-field("dataType"):buffer-value()
          columnFormat = hBuffer:buffer-field("columnFormat"):buffer-value()
          .
        /* add the new column to the dynamic temp table */
        hTable:add-new-field(columnName, dataType, 0, columnFormat).
        hQuery:get-next().
      end.
      hQuery:query-close().
      delete object hQuery no-error.
      hTable:temp-table-prepare("listresult").
      return hTable.
    end.
   else return ?.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

