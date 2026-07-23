//***** Change to "false" for Production *****//
var isTest = "true";
var isBeta = "false";
//***** The Compass user and password *****//
var compassUser = "compass@alliantnational.com";
var compassPass = "a2VvPUhad2RDaERyWk9GcXEhZnN5U2Z5IXRzZnFXWXhKUmhrdU9vV21uSlVDbUhubUJwQWZUR2lTdHpMR2N2UXlsdmVGZlBiZFZnWHlQTE9rWnhYRGplT2V1SFdqTHBFVURmcmplUXhhZXhIdFBXeWxHa2hORmFzUkRLaUxwVUxqR1hL";

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getBaseUrl
// Purpose:     Gets the base Compass URL without the parameters
// Returns:     str:theURL (the Compass base URL)
//**********************************************************************
function getBaseUrl() {
  var subDomain = (isTest == "true" ? "compassdvlp" : (isBeta == "true" ? "compassbeta" : "compass"));
  var environment = (isTest == "true" ? "dvlp" : (isBeta == "true" ? "beta" : "live"));
  var theURL = "https://" + subDomain + ".alliantnational.com:8118/do/action/WService=" + environment + "/act";
  return theURL;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        callCompass
// Purpose:     Utilitizes the XMLHttpRequest object to call an API within
//              Compass. The call is asyncronous meaning that the program
//              will proceed on without getting a response.
// Parameters:  str:user (the compass username)
//              str:pass (the current user's password)
//              str:param (the parameters for the Compass server page)
//              function:cb (the callback function)
// Returns:     str:responseText (the XML from the call - returns to 
//              callback function)
//**********************************************************************
function callCompass(user, pass, param, cb, data) {
  var theURL = getBaseUrl() + "?I1=" + user + "&I2=" + pass + "&I3=" + param
  var data = (data == undefined ? null : data);
  var method = (data == undefined ? "GET" : "POST");

  var xhr = null;
  if (window.XMLHttpRequest) {
    // If IE7, Mozilla, Safari, and so on: Use native object.
    xhr = new XMLHttpRequest();
  }
  else
  {
    if (window.XDomainRequest) {
      // IF can do XDomainRequest
      xhr = new XDomainRequest();
    } else if (window.ActiveXObject) {
       // ...otherwise, use the ActiveX control for IE5.x and IE6.
       xhr = new ActiveXObject('MSXML2.XMLHTTP');
    }
  }

  if (xhr.addEventListener) {
    xhr.addEventListener("readystatechange", function () {
      finishCompassCall(this, xhr, cb);
    });
  } else if (xhr.attachEvent) {
    xhr.attachEvent("readystatechange", function () {
      finishCompassCall(this, xhr, cb);
    });
  }

  try {
    xhr.open(method, theURL);
    xhr.send(data);
  } catch (err) {
    showMessage("Could not complete request. Please try again.", "bad");
    wait("");
  }
}
  
//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        finishCompassCall
// Purpose:     Executes when the XMLHttpRequest is complete
// Parameters:  obj:ev (The event listener)
//              obj:xhr (The XMLHttpRequest object)
//              function:cb (the callback function)
// Returns:     None
//**********************************************************************
function finishCompassCall (ev, xhr, cb) {
  if (ev.readyState === ev.DONE) {
    var ua = window.navigator.userAgent;
    if (xhr.readyState == 4 && xhr.status != 200) {
      showMessage("Could not complete request. Please try again.", "bad");
      wait("");
    } else {
      var parser = new DOMParser();
      cb(parser.parseFromString(xhr.responseText,"text/xml"));
    }
  }
}
  
//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        parseXML
// Purpose:     Parse an XML document
// Parameters:  obj:xmlDoc (xml document object)
// Returns:     array:paramArray (an array of parameter objects from the
//                response or an empty array if there was a fault)
//**********************************************************************
function parseXML(xmlDoc) {
  var paramArray = [];
  var body = getChildNode(xmlDoc.documentElement, "Body");
  var statNode = body.childNodes[1];
  //add the status node description to the array regardless of success or fault
  var paramObj = new Object();
  paramObj.name = statNode.nodeName;
  paramObj.value = statNode.getAttribute('message');
  paramArray.push(paramObj);
  if (statNode.nodeName == "Success") {
    var dataset = body.getElementsByTagName('dataset')[0];
    if (typeof(dataset) == "object") {
      var dsType = dataset.attributes.item(0).value;
      var dsChild = dataset.childNodes;
      switch (dsType) {
        case "parameter":
          for (var i=0; i<dsChild.length; i++) {
            if (dsChild[i].nodeType == 1) {
              var paramAttr = dsChild[i].attributes.item(0);
              var paramObj = new Object();
              paramObj.name = paramAttr.name;
              paramObj.value = paramAttr.value;
              paramArray.push(paramObj);
            }
          }
          break;
        case "agentapp":
          for (var i=0; i<dsChild.length; i++) {
            if (dsChild[i].nodeType == 1) {
              var paramAttr = dsChild[i].attributes;
              var agentApp = new AgentApp();
              for (var j=0; j<paramAttr.length; j++) {
                eval("agentApp." + paramAttr[j].name + " = '" + escapeQuotes(paramAttr[j].value) + "'");
              }
              var paramObj = new Object();
              paramObj.name = agentApp.agentID;
              paramObj.value = agentApp;
              paramArray.push(paramObj);
            }
          }
          break;
        case "SystemProperty":
          for (var i=0; i<dsChild.length; i++) {
            if (dsChild[i].nodeType == 1) {
              var paramAttr = dsChild[i].attributes;
              var doc = new Document();
              for (var j=0; j<paramAttr.length; j++) {
                var str = "";
                switch (paramAttr[j].name) {
                  case "objValue":
                    str = "name";
                    break;
                  case "objID":
                    str = "type";
                    break;
                  case "objName":
                    str = "lnk";
                    break;
                  case "objDesc":
                    str = "seq";
                    break;
                  case "objRef":
                    str = "id";
                    break;
                }
                if (str != "") {
                  eval("doc." + str + " = '" + escapeQuotes(paramAttr[j].value) + "'");
                }
              }
              var paramObj = new Object();
              paramObj.name = doc.seq;
              paramObj.value = doc;
              paramArray.push(paramObj);
            }
          }
          break;
        case "SystemDocument":
          for (var i=0; i<dsChild.length; i++) {
            if (dsChild[i].nodeType == 1) {
              var paramAttr = dsChild[i].attributes;
              var doc = new UserDocument();
              for (var j=0; j<paramAttr.length; j++) {
                var str = "";
                switch (paramAttr[j].name) {
                  case "objType":
                    str = "type";
                    break;
                  case "objID":
                    str = "filename";
                    break;
                }
                if (str != "") {
                  eval("doc." + str + " = '" + escapeQuotes(paramAttr[j].value) + "'");
                }
              }
              var paramObj = new Object();
              paramObj.name = doc.type;
              paramObj.value = doc;
              paramArray.push(paramObj);
            }
          }
          break;
        case "AgentNote": //TODO: replace with AgentAppNote
          for (var i=0; i<dsChild.length; i++) {
            if (dsChild[i].nodeType == 1) {
              var paramAttr = dsChild[i].attributes;
              var note = new UserNote();
              for (var j=0; j<paramAttr.length; j++) {
                var str = "";
                switch (paramAttr[j].name) {
                  case "subject":
                    str = "subject";
                    break;
                  case "noteDate":
                    str = "dateCreated";
                    break;
                  case "username":
                  case "uid":
                    str = "createdBy";
                    break;
                  case "notes":
                    str = "note";
                    break;
                }
                if (str != "") {
                  eval("note." + str + " = '" + escapeQuotes(paramAttr[j].value) + "'");
                }
              }
              var paramObj = new Object();
              paramObj.name = note.subject;
              paramObj.value = note;
              paramArray.push(paramObj);
            }
          }
          break;
      }
    }
  }
  return paramArray;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getChildNode
// Purpose:     Gets the child node by looping through the parent and
//              comparing the node's name by the node we are looking for
// Parameters:  obj:parentNode (Parent node of the XML document)
//              str:nodeName (Name of the node we are looking for)
// Returns:     obj:node (XML node)
//**********************************************************************
function getChildNode(parentNode, nodeName) {
  var node = null;
  for (var i=0; i<parentNode.childNodes.length; i++) {
    node = parentNode.childNodes[i];
    if (node.nodeName == nodeName) {
      break;
    }
  }
  return node;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        encrypt
// Purpose:     Encrypt the passwords for sending to the server
// Parameters:  str:word (the word to encrypt)
// Returns:     str:encrypted (the encrypted word)
// Notes:       The first character is an alpha character that
//              represents the starting position of the word (a=1). The
//              second character is the offset of the alpha character. The 
//              third character is the length of the word. If the
//              length is over 26 characters long, then the fourth
//              character will be represent the same as the third. The
//              next character after the length will be an equal sign.
//              For example, if the first three charaters are "cfd=" then
//              if would represent "364=" which the word would start on
//              character 3 and have a length of 4 with an offset of 6.
//**********************************************************************
function encrypt(word) {
  var maxLength = Math.max(word.length, 128);
  var startOfWord = Math.ceil(Math.random() * 26);
  var offset = Math.ceil(Math.random() * 26);
  var encrypted = String.fromCharCode(startOfWord + 96) + String.fromCharCode(offset + 96);
  for (var i=0;i<Math.ceil(word.length / 26);i++) {
    var subWord = word.substring(i * 26, (i * 26) + 26);
    encrypted += String.fromCharCode(subWord.length + 96);
  }
  encrypted += "=";
  //padding between start of encryption and start of word
  for (var i=0;i<startOfWord - 1;i++) {
    var chr = String.fromCharCode(Math.ceil(Math.random() * 26) + 96);
    encrypted += (Math.ceil(Math.random() * 2) == 1) ? chr.toUpperCase() : chr;
  }
  //encrypt the word
  var encryptWord = "";
  for (var i=0;i<word.length;i++) {
    var unicode = word.charCodeAt(i);
    if (unicode >= 65 && unicode <= 90) {
      unicode += offset;
      if (unicode > 90) {
        unicode -= 26;
      }
    } else if (unicode >= 97 && unicode <= 122) {
      unicode += offset;
      if (unicode > 122) {
        unicode -= 26;
      }
    }
    encryptWord += String.fromCharCode(unicode);
  }
  encrypted += encryptWord;
  //pad from the end of the word to the length of the string
  for (var i=word.length + startOfWord;i<maxLength;i++) {
    var chr = String.fromCharCode(Math.ceil(Math.random() * 26) + 96);
    encrypted += (Math.ceil(Math.random() * 2) == 1) ? chr.toUpperCase() : chr;
  }
  encrypted = encodeURIComponent(btoa(encrypted));
  return encrypted;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        decrypt
// Purpose:     Decrypt the string
// Parameters:  str:encrypted (the word to decrypt)
// Returns:     str:word (the decrypted word)
// Notes:       The first character is an alpha character that
//              represents the starting position of the word (a=1). The
//              second character is the offset of the alpha character. The 
//              third character is the length of the word. If the
//              length is over 26 characters long, then the fourth
//              character will be represent the same as the third. The
//              next character after the length will be an equal sign.
//              For example, if the first three charaters are "cfd=" then
//              if would represent "364=" which the word would start on
//              character 3 and have a length of 4 with an offset of 6.
//**********************************************************************
function decrypt(encrypted) {
  var decrypted = atob(encrypted); //the full decrypted string
  var startOfWord = decrypted.charCodeAt(0) - 96;
  var offset = decrypted.charCodeAt(1) - 96;
  var wordLength = 0;
  var word = "";
  //get the length of the word
  for (var i=3;i<decrypted.indexOf("=");i++) {
    wordLength += decrypted.charCodeAt(i) - 96;
  }
  //loop through the word
  startOfWord = decrypted.indexOf("=") + startOfWord + 1;
  for (var i=startOfWord;i<startOfWord + wordLength;i++) {
    var unicode = decrypted.charCodeAt(i);
    if (unicode >= 65 && unicode <= 90) {
      unicode -= offset;
      if (unicode < 65) {
        unicode += 26;
      }
    } else if (unicode >= 97 && unicode <= 122) {
      unicode -= offset;
      if (unicode < 97) {
        unicode += 26;
      }
    }
    word += String.fromCharCode(unicode);
  }
  return word;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        escapeQuotes
// Purpose:     Escape quotes in the value
// Parameters:  str:word (the word to escape)
// Returns:     str:escapedWord (the escaped word)
// Notes:
//**********************************************************************
function escapeQuotes(word) {
  var escapedWord = "";
  for (var i=0;i<word.length;i++) {
    var unicode = word.charCodeAt(i);
    if (unicode == 34 || unicode == 39) {
      escapedWord += "\\"
    }
    escapedWord += word.charAt(i);
  }
  return escapedWord;
}
