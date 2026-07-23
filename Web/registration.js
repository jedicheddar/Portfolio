//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        setup
// Purpose:     Calls Compass setup the page by getting the session
// Parameters:  None
// Returns:     None
//**********************************************************************
function setup() {
  // for testing only
  //jQuery("#email").val("joliver@alliantnational.com");
  //jQuery("#fullname").val("John");
  //jQuery("#company").val("John");
  //jQuery("#license").val("John-333");
  // clear all errors
  clearError();
  // errors on page loading
  if (jQuery("#error").val().length > 0) {
    showError(true, jQuery("#error").val());
  }
  else if (!getStripeKey().length > 0) {
    showError(false, "Stripe keys not set.");
  }
  // hide the credit type
  show_dropdown(false);
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
// Name:        toggle_checked
// Purpose:     Dynamically create the Stripe shortcode
// Parameters:  None
// Returns:     None
//**********************************************************************
function toggle_checked() {
  if (needCredit() && getStripeKey().length > 0 && validateEmail()) {
    createCheckout(getStripeKey());
    jQuery("#stripe-element").show();
    jQuery("#submit").text("Pay " + jQuery("#price").val());
    show_dropdown(true);
  }
  else {
    jQuery("#stripe-element").hide();
    jQuery("#submit").text("Register");
    jQuery("#need-credit").prop("checked", false);
    show_dropdown(false);
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        register
// Purpose:     Calls Compass to register the participant as well as
//              calls Stripe if the user wants credit
// Parameters:  None
// Returns:     None
//**********************************************************************
function register() {
  if (validateEmail() && validateLicense()) {
    clearError();
    wait(true);
    try {
      jQuery.post (
        my_ajax_obj.ajax_url,
        {
          action: "edu_compass_register",
          email: getEmailAddress(),
          name: jQuery("#fullname").val(),
          company: jQuery("#company").val(),
          license: getLicense(),
          needCE: needCredit(),
          creditType: (needCredit()) ? jQuery("#credit-type").val() : "",
          session: getSessionId(),
        },
        function (error) {
          if (error.length === 0) {
            if (needCredit()) {
              confirmPayment();
            }
            else {
              window.location.href = window.location.origin + "/registration-success";
            }
          }
          else {
            showError(false, error);
            wait(false);
          }
        }
      );
    }
    catch {
      showError(false, "There was a problem.");
      wait(false);
    }
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        validateEmail
// Purpose:     Validates the email address
// Parameters:  None
// Returns:     True or False
//**********************************************************************
function validateEmail() {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const success = emailRegex.test(getEmailAddress());
  if (!success) {
    showError(false, "The email address is invalid.");
    jQuery("#email").focus();
  }
  else  {
    clearError();
  }
  
  return success;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        validateLicense
// Purpose:     Validates the license number
// Parameters:  None
// Returns:     None
//**********************************************************************
function validateLicense() {
  let success = true;
  if (needCredit() && !getLicense()) {
    success = false;
    showError(false, "The license number must be filled in for credit.");
    jQuery("#license").focus();
  }
  else  {
    clearError();
  }
  
  return success;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getStripeKey
// Purpose:     Gets the stripe key for the client JavaScript
// Parameters:  None
// Returns:     str:key (the stripe key)
//**********************************************************************
function getStripeKey() {
  return jQuery("#stripeKey").val();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getEmailAddress
// Purpose:     Gets the typed in email address
// Parameters:  None
// Returns:     str:email (the user's email)
//**********************************************************************
function getEmailAddress() {
  return jQuery("#email").val();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getLicense
// Purpose:     Gets the typed in license number
// Parameters:  None
// Returns:     str:license (the license number)
//**********************************************************************
function getLicense() {
  return jQuery("#license").val();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        getSessionId
// Purpose:     Gets the session
// Parameters:  None
// Returns:     str:id (the session id)
//**********************************************************************
function getSessionId() {
  return jQuery("#session").val();
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        needCredit
// Purpose:     Determine if the person needs credit or not (i.e. the
//              Need Creidt checkbox is checked)
// Parameters:  None
// Returns:     True or False
//**********************************************************************
function needCredit() {
  return jQuery("#need-credit").is(':checked');
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        show_dropdown
// Purpose:     Either show or hide the credit drop down
// Parameters:  bool:show (True if the box should be shown)
// Returns:     True or False
//**********************************************************************
function show_dropdown(show) {
  if (show && jQuery("#credit-type option").length > 1) {
    jQuery("#credit-type").show();
    jQuery("#credit-type-label").show();
  } else {
    jQuery("#credit-type").hide();
    jQuery("#credit-type-label").hide();
  }
}