//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        doExpand
// Purpose:     Expands/Collapses the div sections
// Parameters:  obj:div (The div for the button to toggle)
//              bool:expand (whether to expand the div or not)
// Returns:     None
//**********************************************************************
function doExpand(div, expand) {
  div.classList.toggle("active");
  var panel = div.nextElementSibling;
  if (!expand && panel.style.display != "none"){
    panel.style.display = "none";
  } else {
    panel.style.display = "block";
  } 
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        hideSubmit
// Purpose:     Shows/hides the submit button based on if there is a file,
//              the application is complete, or the parameter is true
// Parameters:  bool;hide (True if the button should be hidden)
// Returns:     None
//**********************************************************************
function hideSubmit(hide) {
  var panel = document.getElementById("submitPanel");
  var displayStyle = "block";
  if (hide || isComplete() || isUnderReview() || !hasFile()) {
    displayStyle = "none";
  }
  panel.style.display = displayStyle;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        wait
// Purpose:     Shows/hides the wait spinner
// Parameters:  str:txt (The text to show the user)
// Returns:     None
//**********************************************************************
function wait(txt) {
  var spinner = document.getElementById("wait");
  var displayStyle = "block";
  if (txt == "") {
    displayStyle = "none";
  }
  spinner.firstChild.innerHTML = txt;
  spinner.style.display = displayStyle;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        showMessage
// Purpose:     Shows/hides the status message
// Parameters:  str:txt (The text to show the user)
//              str:type (The class of the status)
// Returns:     None
//**********************************************************************
function showMessage(txt, type) {
  var contentDiv = document.getElementById("contentMessage");
  var loginDiv = document.getElementById("loginMessage");
  contentDiv.className = type;
  contentDiv.innerHTML = txt;
  loginDiv.className = type;
  loginDiv.innerHTML = txt;
  wait("");
  if (txt == "") {
    contentDiv.style.display = "none";
    loginDiv.style.display = "none";
  }
  else {
    contentDiv.style.display = "block";
    loginDiv.style.display = "block";
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        showLogin
// Purpose:     Shows the login div
// Parameters:  None
// Returns:     None
//**********************************************************************
function showLogin() {
  var loginDiv = document.getElementById("login");
  var contentDiv = document.getElementById("content");
  var docTypeDiv = document.getElementById("documentTypes");
  loginDiv.style.display = "block";
  contentDiv.style.display = "none";
  docTypeDiv.innerHTML = "";
  clearDiv("title");
  clearDiv("logout");
  //we should probably disable the wait screen and status message
  wait("");
  showMessage("", "");
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        showContent
// Purpose:     Shows the content div and hides the login div
// Parameters:  None
// Returns:     None
//**********************************************************************
function showContent() {
  var loginDiv = document.getElementById("login");
  var contentDiv = document.getElementById("content");
  loginDiv.style.display = "none";
  contentDiv.style.display = "block";
  //push to the "New" stage
  moveStatus("New");
  //disable the input and button fields if complete
  var buttonField = contentDiv.getElementsByTagName("BUTTON");
  var inputField = contentDiv.getElementsByTagName("INPUT");
  for (var i=0; i<inputField.length; i++) {
    inputField[i].disabled = isComplete();
  }
  for (var i=0; i<buttonField.length; i++) {
    if (!buttonField[i].classList.contains("accordion")) {
      buttonField[i].disabled = isComplete();
    }
  }
  //clear the username and password
  document.getElementById("uname").value = "";
  document.getElementById("psw").value = "";
  //hide the button
  hideSubmit(true);
  //we should probably disable the wait screen and status message
  wait("");
  showMessage("", "");
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        doLogin
// Purpose:     Logs the user into the site
// Parameters:  None
// Returns:     None
//**********************************************************************
function doLogin() {
  var user = document.getElementById("uname").value;
  var pass = document.getElementById("psw").value;
  var btn = document.getElementById("bLogin");
  //handling the response is done within the call
  wait("Logging in...");
  callCompass(compassUser, compassPass, "agentAppUserGet&janusername=" + user + "&janpassword=" + encrypt(pass), function(response) {
    var param = parseXML(response);
    if (param[0].name == "Success") {
      var object = param[1].value;
      moveStatus(object.stat);
      //set the title of the page
      createParagraph("title", "Application to be an " + object.typeDesc);
      createParagraph("title", object.agentName);
      createLink("logout", "javascript:showLogin();", "Logout");
      createParagraph("logout", "ID: " + object.agentID);
      // get the documents we need
      callCompass(compassUser, compassPass, "systemPropsGet&appCode=AMD&objAction=Application&objProperty=Document&objID=" + object.typeDesc, function(response) {
        var param = parseXML(response);
        if (param[0].name == "Success") {
          var docArray = [];
          for (var i=1; i<param.length; i++) {
            docArray.push(param[i].value);
          }
          docArray.sort(sortDocTypes);
          var req = document.createElement("i");
          req.innerHTML = "&#42; denotes required<br>";
          req.innerHTML += "Complete form Agency Application &#8212; Title and Escrow if the agency has an escrow account OR complete form Agency Application &#8212; Title Only if the agency does not have an escrow account."; 
          document.getElementById("documentTypes").appendChild(req);
          for (var i=0; i<docArray.length; i++) {
            createDocumentType(docArray[i], object.agentID, object.applicationID);
          }
          //getAgentAppNotes(object.agentID, object.applicationID);
          getSystemDocuments(object.agentID, object.applicationID);
          doExpand(document.getElementById('docExpand'), true);
          doExpand(document.getElementById('noteExpand'), true);
        }
      });
    } else {
      showMessage(param[0].value, "bad");
      wait("");
    }
  });
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        sortDocType
// Purpose:     Sorts the documents by the document sequence
// Parameters:  None
// Returns:     None
//**********************************************************************
function sortDocTypes(a, b) {
  return a.seq - b.seq;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        moveStatus
// Purpose:     Moves the status of the status bar to what the
//              application's status is
// Parameters:  str:stat (The status of the application)
// Returns:     None
//**********************************************************************
function moveStatus(stat) {
  var statArray = {"New":1, "In Process":2, "Submitted":3, "R":4, "A":4, "D":5, "C":5, "X":5};
  var currIntStat = document.getElementById("currIntStat").value;
  var intStat = statArray[stat];
  //push to the next stage
  var statElem = document.getElementById("progress-wrapper");
  //only push to the desired stage if greater than the current stage
  if (intStat >= currIntStat) {
    for (var i=currIntStat; i<intStat; i++) {
      statElem.childNodes[(i * 2) - 1].classList.add("completed");
    }
    statElem.childNodes[(i * 2) - 1].classList.add("active");
    document.getElementById("currIntStat").value = intStat;
  }
  if (intStat == 5) {
    statElem.childNodes[(intStat * 2) - 1].classList.add("completed");
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        isComplete
// Purpose:     Checks to see if the application is complete or not
// Parameters:  None
// Returns:     True if the application is in "Complete" status
//**********************************************************************
function isComplete() {
  var currIntStat = document.getElementById("currIntStat").value;
  return (currIntStat == 5);
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        isUnderReview
// Purpose:     Checks to see if the application is under review or not
// Parameters:  None
// Returns:     True if the application is in "Under Review" status
//**********************************************************************
function isUnderReview() {
  var currIntStat = document.getElementById("currIntStat").value;
  return (currIntStat == 4);
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        dropFile
// Purpose:     Used when dropping one or multiple files to the specified
//              area.
// Parameters:  event:ev (The event)
//              str:id (The id of the span within the form)
// Returns:     None
//**********************************************************************
function dropFile(ev, id) {
  // console.log("Drop");
  // ev.preventDefault();
  // // If dropped items aren't files, reject them
  // var dt = ev.dataTransfer;
  // if (dt.items) {
    // // Use DataTransferItemList interface to access the file(s)
    // for (var i=0; i < dt.items.length; i++) {
      // if (dt.items[i].kind == "file") {
        // var f = dt.items[i].getAsFile();
        // processFile(f, id);
      // }
    // }
  // } else {
    // // Use DataTransfer interface to access the file(s)
    // for (var i=0; i < dt.files.length; i++) {
      // processFile(f, id);
    // }  
  // }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        startProcessFile
// Purpose:     Begin the process of loading a file to Compass
// Parameters:  str:spanID (The ID of the span tag to append the list to)
// Returns:     None
//**********************************************************************
function startProcessFile(spanID) {
  var agent = document.getElementById("agent");
  var app = document.getElementById("appID");
  var file = document.getElementById("file_" + spanID);
  var iframe = document.getElementById("hidden_form_" + spanID);
  iframe.setAttribute("onload", "getSystemDocuments('" + agent.value + "', '" + app.value + "')");
  if (file.files.length > 0) {
    wait("Submitting document...");
    return true;
  }
  return false;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        deleteDocument
// Purpose:     Delete a file from Sharefile
// Parameters:  str:file (The filename to delete)
//              str:type (The type of document to remove)
// Returns:     None
//**********************************************************************
function deleteDocument(file, type) {
  var agent = document.getElementById("agent");
  var app = document.getElementById("appID");
  if (confirm("Do you want to delete the document?")) {
    wait("Deleting Document...");
    callCompass(compassUser, compassPass, "agentAppDocumentDelete&AgentID=" + agent.value + "&AppID=" + app.value + "&file=" + encodeURIComponent(file) + "&type=" + type.split("_").join(" "), function(response) {
      var param = parseXML(response);
      if (param[0].name == "Success") {
        getSystemDocuments(agent.value, app.value);
      } else {
        showMessage(param[0].value, "bad");
        wait("");
      }
    });
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getSystemDocuments
// Purpose:     Get the system documents from the table
// Parameters:  str:agentID (The agent ID)
//              str:appID (The application ID)
// Returns:     None
//**********************************************************************
function getSystemDocuments(agentID, appID) {
  callCompass(compassUser, compassPass, "agentAppSysDocsGet&ID=" + agentID + "-" + appID, function(response) {
    removeFiles();
    var param = parseXML(response);
    if (param[0].name == "Success") {
      if (param.length > 1) {
        var fileName = [];
        for (var i=1; i<param.length; i++) {
          var doc = param[i].value;
          if (fileName.indexOf(doc.type + "-" + doc.filename) == -1) {
            processFile(doc.filename, doc.type.split(" ").join("_"));
            fileName.push(doc.type + "-" + doc.filename);
          }
        }
      } else {
        hideSubmit(true);
        moveStatus("New");
      }
    } else {
      showMessage(param[0].value, "bad");
    }
    showContent();
    hideSubmit(false);
  });
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getAgentAppNotes
// Purpose:     Get the applicant notes
// Parameters:  str:agentID (The agent ID)
//              str:appID (The application ID)
// Returns:     None
//**********************************************************************
function getAgentAppNotes(agentID, appID) {
  callCompass(compassUser, compassPass, "agentAppNotesGet&agentID=" + agentID + "&applicationID=" + appID, function(response) {
    var param = parseXML(response);
    if (param[0].name == "Success") {
      if (param.length > 1) {
        for (var i=1; i<param.length; i++) {
          var note = param[i].value;
          processNote(note);
        }
        
      }
    } else {
      showMessage(param[0].value, "bad");
    }
  });
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        readyForReview
// Purpose:     Moves the progress bar and call compass
// Parameters:  None
// Returns:     None
//**********************************************************************
function readyForReview() {
  var agent = document.getElementById("agent");
  var app = document.getElementById("appID");
  wait("Notifying Alliant National...");
  callCompass(compassUser, compassPass, "agentAppDateSubmittedSet&agentID=" + agent.value + "&applicationID=" + app.value, function(response) {
    var param = parseXML(response);
    if (param[0].name == "Success") {
      showMessage("Notification Sent Successfully!", "good");
      moveStatus("Submitted");
      window.scrollTo(0, 0);
    } else {
      showMessage(param[0].value, "bad");
    }
  });
}
  
//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        captureKey
// Purpose:     Capture the return key and change the password rather
//              than perform a search
// Parameters:  event:e (the keyboard event)
// Returns:     Nothing
//**********************************************************************
function captureKey(e) {
  if (e.keyCode == 13) {
    doLogin();
    return false;
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        hasFile
// Purpose:     Determines if the applicant has uploaded at least one
//              file or not
// Parameters:  None
// Returns:     True if the applicant has uploaded at least one file
//**********************************************************************
function hasFile() {
  var uploaded = false;
  var div = document.getElementById("documentTypes");
  for (var i=0; i<div.childNodes.length; i++) {
    var formNode = div.childNodes[i];
    if (formNode.tagName == "FORM" && !uploaded) {
      var spanNode = formNode.getElementsByTagName("SPAN")[0];
      if (spanNode.lastChild.tagName == "UL") {
        uploaded = true;
      }
    }
  }
  return uploaded;
}