//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        setup
// Purpose:     Calls Compass setup the page by getting the session
// Parameters:  None
// Returns:     None
//**********************************************************************
function setup() {
  jQuery("#content").show();
  jQuery("#feedback-success").hide();
  // for testing only
  jQuery("#email").val("joliver@alliantnational.com");
  jQuery("#fullname").val("John");
  jQuery("#company").val("John");
  jQuery("#license").val("John-333");
  // clear all errors
  clearError();
  // errors on page loading
  if (jQuery("#error").val().length > 0) {
    showError(true, jQuery("#error").val());
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        showError
// Purpose:     Show the error
// Parameters:  bool:pageError (true if the content should be hidden)
//              str:msg (the error message)
// Returns:     None
//**********************************************************************
function showError(pageError, msg) {
  if (pageError) {
    jQuery("#content").hide();
  }
  const container = jQuery(pageError ? "#page-error" : "#user-error");
  container.text(msg);
  container.show();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        clearError
// Purpose:     Hide the error
// Returns:     None
//**********************************************************************
function clearError() {
  jQuery("#page-error").hide();
  jQuery("#user-error").hide();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        wait
// Purpose:     Show/Hide the waiting div
// Parameters:  bool:isLoading (true to show the wait screen)
//              str:msg (optional mesage to say)
// Returns:     None
//**********************************************************************
function wait(isLoading, msg = '') {
  if (isLoading) {
    jQuery("#wait").show();
    if (msg === '') {
      msg = "Registering...";
    }
    jQuery("#wait-msg").text(msg);
  }
  else {
    jQuery("#wait").hide();
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        sendFeedback
// Purpose:     Calls Compass to send the feedback on behalf of the
//              participant
// Parameters:  None
// Returns:     None
//**********************************************************************
function feedback() {
  clearError();
  wait(true, "Submitting");
  try {
    jQuery.post (
      my_ajax_obj.ajax_url,
      {
        action: "edu_compass_feedback",
        score: jQuery("#score").val(),
        notes: jQuery("#notes").val(),
        session: jQuery("#session").val(),
        participant: jQuery("#participant").val(),
      },
      function (error) {
        if (error.length === 0) {
          jQuery("#content").hide();
          jQuery("#feedback-success").show();
          wait(false);
        }
        else {
          showError(false, error);
          wait(false);
        }
      }
    );
  }
  catch (e) {
    showError(false, e);
    wait(false);
  }
}
