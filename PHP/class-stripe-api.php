<?php
  /* Purpose: Used for calling Stripe to pay for the course */
  
if (!defined('ABSPATH') ) {
	exit;
}

require_once 'stripe/init.php';

class EDU_Stripe_API {
  private $stripe;
  
  function __construct($key) {
    $this->stripe = new \Stripe\StripeClient($key);
  }
  
  function createCheckoutSession($name, $price, $email) {
    try {
      $checkout = $this->stripe->checkout->sessions->create([
        'line_items' => [
          [
            'price_data' => [
              'currency' => 'usd',
              'product_data' => ['name' => $name],
              'unit_amount' => $price * 100,
            ],
            'quantity' => 1,
          ],
        ],
        'customer_email' => $email,
        'mode' => 'payment',
        'ui_mode' => 'custom',
        'return_url' => home_url('/') . 'registration-success/?transaction={CHECKOUT_SESSION_ID}',
      ]);
      return $checkout->client_secret;
    } catch (Exception $e) {
      error_log($e->getMessage());
    }
  }
}
?>
