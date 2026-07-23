//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        clearDiv
// Purpose:     Removes the innerHTML from a div node
// Parameters:  str:div (The div to append the paragraph to)
// Returns:     None
//**********************************************************************
function clearDiv(div) {
  document.getElementById(div).innerHTML = "";
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        createParagraph
// Purpose:     Creates a paragraph node and appends it to the div
// Parameters:  str:div (The div to append the paragraph to)
//              str:txt (The text of the paragraph)
// Returns:     None
//**********************************************************************
function createParagraph(div, txt) {
  var para = document.createElement("p");
  var textNode = document.createTextNode(txt);
  para.appendChild(textNode);
  document.getElementById(div).appendChild(para);
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        createLink
// Purpose:     Creates a paragraph node and appends it to the div
// Parameters:  str:div (The div to append the paragraph to)
//              str:lnk (The link)
//              str:txt (The text of the paragraph)
// Returns:     None
//**********************************************************************
function createLink(div, lnk, txt) {
  var tag = document.createElement("a");
  tag.setAttribute("href", lnk);
  var textNode = document.createTextNode(txt);
  tag.appendChild(textNode);
  document.getElementById(div).appendChild(tag);
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        createDocumentType
// Purpose:     Creates a document type
// Parameters:  object:object (The document class)
//              str:agentID (The agent ID)
//              str:appID (The application ID)
// Returns:     None
//**********************************************************************
function createDocumentType(object, agentID, appID) {
  var spanID = object.id.split(" ").join("_");
  var div = document.createElement("form");
  div.setAttribute("id", "dropFile");
  // div.setAttribute("ondragover", "this.className='overlay';event.preventDefault();");
  // div.setAttribute("ondragenter", "return false;");
  // div.setAttribute("ondrop", "dropFile(event, '" + spanID + "');this.className='';");
  // div.setAttribute("ondragleave", "this.className='';");
  div.setAttribute("method", "post");
  div.setAttribute("enctype", "multipart/form-data");
  div.setAttribute("action", getBaseUrl());
  div.setAttribute("target", "hidden_form_" + spanID);
  //in order to not have the page refresh, create a hidden iframe
  var iframe = document.createElement("iframe");
  iframe.setAttribute("style", "display: none");
  iframe.setAttribute("id", "hidden_form_" + spanID);
  iframe.setAttribute("name", "hidden_form_" + spanID);
  div.appendChild(iframe);
  var span = document.createElement("span");
  span.setAttribute("id", spanID);
  div.appendChild(span);
  if (object.lnk != "") {
    var lnk = document.createElement("a");
    lnk.setAttribute("href", object.lnk);
    lnk.innerHTML = object.name;
    span.appendChild(lnk);
  } else {
    var title = document.createElement("b");
    title.innerHTML = object.name;
    span.appendChild(title);
  }
  var btn = document.createElement("input");
  btn.setAttribute("type", "button");
  btn.setAttribute("onclick", "this.nextElementSibling.click();");
  btn.setAttribute("value", "Submit document...");
  div.appendChild(btn);
  var file = document.createElement("input");
  file.setAttribute("type", "file");
  file.setAttribute("style", "display: none");
  file.setAttribute("onchange", "startProcessFile('" + spanID + "');this.parentNode.submit();");
  file.setAttribute("name", "filename");
  file.setAttribute("id", "file_" + spanID);
  file.setAttribute("accept", ".docx, .doc, .xlsx, .xls, .ppt, .pptx, .pdf, .txt");
  div.appendChild(file);
  //because the form is being submitted, we need to add additional parameters to the "action" line
  var I1 = document.createElement("input");
  I1.setAttribute("type", "text");
  I1.setAttribute("style", "display: none");
  I1.setAttribute("name", "I1");
  I1.setAttribute("value", compassUser);
  div.appendChild(I1);
  var I2 = document.createElement("input");
  I2.setAttribute("type", "text");
  I2.setAttribute("style", "display: none");
  I2.setAttribute("name", "I2");
  I2.setAttribute("value", compassPass);
  div.appendChild(I2);
  var I3 = document.createElement("input");
  I3.setAttribute("type", "text");
  I3.setAttribute("style", "display: none");
  I3.setAttribute("name", "I3");
  I3.setAttribute("value", "cronAgentAppDocument");
  div.appendChild(I3);
  var I8 = document.createElement("input");
  I8.setAttribute("type", "text");
  I8.setAttribute("style", "display: none");
  I8.setAttribute("name", "I8");
  I8.setAttribute("value", "Q");
  div.appendChild(I8);
  var agent = document.createElement("input");
  agent.setAttribute("type", "text");
  agent.setAttribute("style", "display: none");
  agent.setAttribute("name", "agent");
  agent.setAttribute("id", "agent");
  agent.setAttribute("value", agentID);
  div.appendChild(agent);
  var app = document.createElement("input");
  app.setAttribute("type", "text");
  app.setAttribute("style", "display: none");
  app.setAttribute("name", "appID");
  app.setAttribute("id", "appID");
  app.setAttribute("value", appID);
  div.appendChild(app);
  var objID = document.createElement("input");
  objID.setAttribute("type", "text");
  objID.setAttribute("style", "display: none");
  objID.setAttribute("name", "objID");
  objID.setAttribute("id", "objID_" + spanID)
  objID.setAttribute("value", object.type);
  div.appendChild(objID);
  var objValue = document.createElement("input");
  objValue.setAttribute("type", "text");
  objValue.setAttribute("style", "display: none");
  objValue.setAttribute("name", "objValue");
  objValue.setAttribute("id", "objValue_" + spanID)
  objValue.setAttribute("value", object.name);
  div.appendChild(objValue);
  var objValue = document.createElement("input");
  objValue.setAttribute("type", "text");
  objValue.setAttribute("style", "display: none");
  objValue.setAttribute("name", "objRef");
  objValue.setAttribute("id", "objRef_" + spanID)
  objValue.setAttribute("value", object.id);
  div.appendChild(objValue);
  document.getElementById("documentTypes").appendChild(div);
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        processFile
// Purpose:     Used to process a single file
// Parameters:  str:file (The filename)
//              str:spanID (The ID of the span tag to append the list to)
// Returns:     None
//**********************************************************************
function processFile(file, spanID) {
  var span = document.getElementById(spanID);
  var ul = document.createElement("ul");
  var li = document.createElement("li");
  var btn = document.createElement("a");
  btn.setAttribute("title", "Delete document");
  btn.setAttribute("onclick", "event.preventDefault();deleteDocument('" + file + "', '" + spanID + "')");
  btn.innerHTML = "Delete";
  li.appendChild(btn);
  li.innerHTML = li.innerHTML + "(Submitted) " + file;
  if (span != undefined ) {
    if (span.lastChild.tagName == "UL") {
      ul = span.lastChild;
    }
    ul.appendChild(li);
    span.appendChild(ul);
    //push to the "Started" stage
    moveStatus("In Process");
    document.getElementById("file_" + spanID).value = "";
  } 
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        processNote
// Purpose:     Used to process a single note
// Parameters:  obj:obj (The instance of the note "Class")
// Returns:     None
//**********************************************************************
function processNote(obj) {
  var noteEditor = document.getElementById("noteEditor");
  var innerText = noteEditor.value;
  var noteText = "[ " + obj.dateCreated.toUpperCase() + " | " + obj.createdBy.toUpperCase() + " | " + obj.subject.toUpperCase() + " ]\r\n" + obj.note;
  if (innerText != "") {
    noteText = innerText + "\r\n\r\n" + noteText;
  }
  noteEditor.value = noteText;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        removeFiles
// Purpose:     Used to remove the files from the document types div
// Parameters:  None
// Returns:     None
//**********************************************************************
function removeFiles() {
  var div = document.getElementById("documentTypes");
  for (var i=0; i<div.childNodes.length; i++) {
    var formNode = div.childNodes[i];
    if (formNode.tagName == "FORM") {
      var spanNode = formNode.getElementsByTagName("SPAN")[0];
      if (spanNode.lastChild.tagName == "UL") {
        spanNode.removeChild(spanNode.lastChild);
      }
    }
  }
}