//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        AgentApp
// Purpose:     "Class" for an agent application
// Members:     agentID
//              agentName
//              appID
//              dateStarted
//              dateStopped
//              dateApproved
//              dateSigned
//              user
//              pass
//              reason
//              stateID
//              stateName
//              type
//              stat
//**********************************************************************
class AgentApp {
  constructor() {
    this.agentID       = "";
    this.agentName     = "";
    this.applicationID = "";
    this.datestarted   = "";
    this.datestopped   = "";
    this.dateapproved  = "";
    this.datesigned    = "";
    this.username      = "";
    this.password      = "";
    this.reasoncode    = "";
    this.stateID       = "";
    this.stateName     = "";
    this.typeofapp     = "";
    this.stat          = "";
  }
  getInfo() {
    return 'agentID: ' + this.agentID + '\n' +
           'appID: ' + this.applicationID + '\n' +
           'datestarted: ' + this.datestarted + '\n' +
           'datestopped: ' + this.datestopped + '\n' +
           'dateapproved: ' + this.dateapproved + '\n' +
           'datesigned: ' + this.datesigned + '\n' +
           'user: ' + this.username + '\n' +
           'pass: ' + this.password + '\n' +
           'reason: ' + this.reasoncode + '\n' +
           'stateID: ' + this.stateID + '\n' +
           'type: ' + this.typeofapp + '\n' +
           'stat: ' + this.stat;
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        Document
// Purpose:     "Class" for a document
// Members:     name
//              type
//              lnk
//**********************************************************************
class Document {
  constructor() {
    this.name = "";
    this.type = "";
    this.lnk  = "";
    this.seq  = "";
    this.id   = "";
  }
  getInfo() {
    return "name: " + this.name + '\n' +
           "type: " + this.type + '\n' +
           "seq: " + this.seq + '\n' +
           "link: " + this.lnk;
  };
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        UserDocument
// Purpose:     "Class" for a user document
// Members:     filename
//              type
//**********************************************************************
class UserDocument {
  constructor() {
    this.filename = "";
    this.type     = "";
  }
  getInfo() {
    return "filename: " + this.filename + '\n' +
           "type: " + this.type;
  };
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        UserNote
// Purpose:     "Class" for a user document
// Members:     subject
//              createdBy
//              dateCreated
//              note
//**********************************************************************
class UserNote {
  constructor() {
    this.subject = "";
    this.createdBy = "";
    this.dateCreated = "";
    this.note = "";
  }
  getInfo() {
    return "subject: " + this.subject + '\n' +
           "createdBy: " + this.createdBy + '\n' +
           "dateCreated: " + this.dateCreated + '\n' +
           "note: " + this.note;
  };
}