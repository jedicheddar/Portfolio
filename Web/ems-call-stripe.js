let checkout = null;

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        createCheckout
// Purpose:     Create a checkout session
// Parameters:  str:key (the publish key for Stripe)
// Returns:     None
//**********************************************************************
async function createCheckout(key) {
  if (checkout === null) {
    wait(true, "Setting up Stripe...");
    const appearance = {
      theme: 'stripe',
    };
    try {
      stripe = Stripe(atob(key));
      checkout = await stripe.initCheckout({
        fetchClientSecret,
        elementsOptions: { appearance },
      });
      
      const paymentElement = checkout.createPaymentElement();
      paymentElement.mount("#stripe-element");
      wait(false);
    }
    catch {
      showError(false, "Could not contact Stripe.");
      wait(false);
    }
  }
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        fetchClientSecret
// Purpose:     Returns the client secret from the server using AJAX
// Parameters:  None
// Returns:     None
//**********************************************************************
async function fetchClientSecret() {
  clientSecret = await jQuery.post (
    my_ajax_obj.ajax_url,
    {
      action: "edu_stripe_client_secret",
      session: getSessionId(),
      email: getEmailAddress(),
      env: jQuery("#env").val(),
    }
  );
  return clientSecret;
}

//**********************************************************************
// Author:      John Oliver (joliver)
// Name:        confirmPayment
// Purpose:     Uses stripe.confirmPayment to confirm payment
// Parameters:  None
// Returns:     None
//**********************************************************************
async function confirmPayment() {
  try {
    checkout.confirm().then((checkoutResult) => {
      if (checkoutResult.type === 'error') {
        showError(false, checkoutResult.error.message);
        wait(false);
      }
    });
  }
  catch {
    showError(false, "Could not confirm Stripe.");
    wait(false);
  }
}