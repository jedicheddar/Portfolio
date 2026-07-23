<?php
/*
  Plugin Name: Education
  Version: 2.0
  Author: John Oliver
  Description: Plugin to handle the Stripe payment for Course Registration
  Text Domain: edu
*/

// used for security
if (!defined('ABSPATH')){
  exit;
}

require_once 'class-compass-api.php';
require_once 'class-participant-api.php';
require_once 'class-feedback-api.php';
require_once 'class-stripe-api.php';

// compass and stripe environment is based on the querystring
$edu_setting_compass_env = '';
if (isset($_GET['E'])) {
  $edu_setting_compass_env = strtoupper($_GET['E']);
}
else if (isset($_GET['e'])) {
  $edu_setting_compass_env = strtoupper($_GET['e']);
}
else if (isset($_POST['env'])) {
  $edu_setting_compass_env = $_POST['env'];
}

// check the settings if no querystring passed in
if ($edu_setting_compass_env == '') {
  $edu_setting_compass_env = get_option('edu_setting_compass_env');
}

// if no environment is passed in,  assume LIVE
// John Oliver - I just want it noted that this is a really bad idea!!!
if ($edu_setting_compass_env == 'T' || $edu_setting_compass_env == 'ALFA') {
  define('COMPASS_ENV', 'ALFA');
  define('STRIPE_TEST', true);
}
else if ($edu_setting_compass_env == 'B' || $edu_setting_compass_env == 'BETA') {
  define('COMPASS_ENV', 'BETA');
  define('STRIPE_TEST', true);
}
else {
  define('COMPASS_ENV', 'LIVE');
  define('STRIPE_TEST', false);
}

/* used to initialize the plugin */
add_action('init', 'edu_initialize');
function edu_initialize() {
  add_action('wp_enqueue_scripts', 'edu_plugin_scripts');
  add_action('wp_ajax_edu_stripe_client_secret', 'edu_stripe_client_secret');
  add_action('wp_ajax_edu_compass_register', 'edu_compass_register');
  add_action('wp_ajax_edu_compass_feedback', 'edu_compass_feedback');
  add_action('wp_ajax_nopriv_edu_stripe_client_secret', 'edu_stripe_client_secret');
  add_action('wp_ajax_nopriv_edu_compass_register', 'edu_compass_register');
  add_action('wp_ajax_nopriv_edu_compass_feedback', 'edu_compass_feedback');
  add_shortcode('edu_agent_info', 'edu_agent_info_handler');
  add_shortcode('edu_course_info', 'edu_course_info_handler');
  add_shortcode('edu_credit_dropdown', 'edu_credit_dropdown_handler');
  add_shortcode('edu_hidden_inputs', 'edu_hidden_inputs_handler');
  add_shortcode('edu_participant_registered', 'edu_participant_registered_handler');
  add_shortcode('edu_feedback_success', 'edu_feedback_success_handler');
  // the menu
  if (is_admin()) {
    add_options_page('Education Settings', 'Education', 'manage_options', 'edu_settings', 'edu_options');
    add_action('admin_init', 'save_edu_options');
  }
}

function edu_plugin_scripts() {
  // registration page
  if (is_page('registration')) {
    wp_enqueue_script('ems-stripe', 'https://js.stripe.com/basil/stripe.js');
    wp_enqueue_script('ems-call-stripe', get_template_directory_uri() . '/js/ems-call-stripe.js', array('json2', 'jquery'));
    wp_enqueue_script('ems-registration', get_template_directory_uri() . '/js/registration.js', array('jquery'));
    wp_localize_script(
      'ems-registration',
      'my_ajax_obj',
      array(
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce'    => wp_create_nonce('registration'),
      )
    );
  }
  // feedback page
  if (is_page('course-feedback')) {
    wp_enqueue_script('ems-course-feedback', get_template_directory_uri() . '/js/feedback.js', array('jquery'));
    wp_localize_script(
      'ems-course-feedback',
      'my_ajax_obj',
      array(
        'ajax_url' => admin_url('admin-ajax.php'),
        'nonce'    => wp_create_nonce('course-feedback'),
      )
    );
  }
  if (is_page('registration') || is_page('registration-success') || is_page('course-feedback')) {
    wp_enqueue_style('registration', get_template_directory_uri() . '/css/registration.css');
  }
}

function edu_options() {
  $edu_setting_compass_env     = get_option('edu_setting_compass_env');
  ?>
  <style>
  .section {
    border: 1px solid #005295;
    background: #FFFFFF;
    color: #005295;
    padding: 5px;
    font-size: 16pt;
    width: 50%;
  }
  input[type="text"] {
    width: 650px;
  }
  input[type="radio"] + label {
    display: inline-block;
    width: 75px;
  }
  </style>
  <h1>Education Settings</h1>
  <form method="post" action="options.php">
    <?php settings_fields('edu_settings'); ?>
    <?php do_settings_sections('edu_settings'); ?>
    <div class="section">Compass</div>
    <table class="form-table">
      <tr valign="top">
        <th scope="row">Environment</th>
        <td>
          <input type="radio" name="edu_setting_compass_env" value="ALFA" <?php if ($edu_setting_compass_env == 'ALFA') { ?> checked <?php } ?>>
          <label for="ALFA">Test</label>
          <input type="radio" name="edu_setting_compass_env" value="BETA" <?php if ($edu_setting_compass_env == 'BETA') { ?> checked <?php } ?>>
          <label for="BETA">Beta</label>
          <input type="radio" name="edu_setting_compass_env" value="LIVE" <?php if ($edu_setting_compass_env == 'LIVE') { ?> checked <?php } ?>>
          <label for="LIVE">Production</label>
        </td>
      </tr>
      <tr valign="top">
        <th scope="row">Test Username</th>
        <td><input type="text" name="edu_setting_compass_test_username" value="<?php echo esc_attr(get_option('edu_setting_compass_test_username')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Test Encrypted Password</th>
        <td><input type="text" name="edu_setting_compass_test_password" value="<?php echo esc_attr(get_option('edu_setting_compass_test_password')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Beta Username</th>
        <td><input type="text" name="edu_setting_compass_beta_username" value="<?php echo esc_attr(get_option('edu_setting_compass_beta_username')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Beta Encrypted Password</th>
        <td><input type="text" name="edu_setting_compass_beta_password" value="<?php echo esc_attr(get_option('edu_setting_compass_beta_password')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Live Username</th>
        <td><input type="text" name="edu_setting_compass_live_username" value="<?php echo esc_attr(get_option('edu_setting_compass_live_username')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Live Encrypted Password</th>
        <td><input type="text" name="edu_setting_compass_live_password" value="<?php echo esc_attr(get_option('edu_setting_compass_live_password')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Registration Success Message</th>
        <td><input type="text" name="edu_setting_compass_registration_success_message" value="<?php echo esc_attr(get_option('edu_setting_compass_registration_success_message')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Feedback Success Message</th>
        <td><input type="text" name="edu_setting_compass_feedback_success_message" value="<?php echo esc_attr(get_option('edu_setting_compass_feedback_success_message')); ?>" /></td>
      </tr>
    </table>
    <div class="section">Stripe</div>
    <table class="form-table">
      <tr valign="top">
        <th scope="row">Test Publish Key</th>
        <td><input type="text" name="edu_setting_stripe_test_publish_key" value="<?php echo esc_attr(get_option('edu_setting_stripe_test_publish_key')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Test Secret Key</th>
        <td><input type="text" name="edu_setting_stripe_test_secret_key" value="<?php echo esc_attr(get_option('edu_setting_stripe_test_secret_key')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Live Publish Key</th>
        <td><input type="text" name="edu_setting_stripe_live_publish_key" value="<?php echo esc_attr(get_option('edu_setting_stripe_live_publish_key')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Live Secret Key</th>
        <td><input type="text" name="edu_setting_stripe_live_secret_key" value="<?php echo esc_attr(get_option('edu_setting_stripe_live_secret_key')); ?>" /></td>
      </tr>
      <tr valign="top">
        <th scope="row">Success Message</th>
        <td><input type="text" name="edu_setting_stripe_success_message" value="<?php echo esc_attr(get_option('edu_setting_stripe_success_message')); ?>" /></td>
      </tr>
    </table>
    <?php submit_button(); ?>
  </form>
  <?php
}

function save_edu_options() {
  register_setting('edu_settings', 'edu_setting_compass_env');
  register_setting('edu_settings', 'edu_setting_compass_test_username');
  register_setting('edu_settings', 'edu_setting_compass_test_password');
  register_setting('edu_settings', 'edu_setting_compass_beta_username');
  register_setting('edu_settings', 'edu_setting_compass_beta_password');
  register_setting('edu_settings', 'edu_setting_compass_live_username');
  register_setting('edu_settings', 'edu_setting_compass_live_password');
  register_setting('edu_settings', 'edu_setting_compass_registration_success_message');
  register_setting('edu_settings', 'edu_setting_compass_feedback_success_message');
  register_setting('edu_settings', 'edu_setting_stripe_test_publish_key');
  register_setting('edu_settings', 'edu_setting_stripe_test_secret_key');
  register_setting('edu_settings', 'edu_setting_stripe_live_publish_key');
  register_setting('edu_settings', 'edu_setting_stripe_live_secret_key');
  register_setting('edu_settings', 'edu_setting_stripe_success_message');
}

/* handlers for the shortcodes */
function edu_agent_info_handler() {
  $compass = get_compass_class();
  if (is_object($compass)) {
    return $compass->getAgentLogoOrName();
  }
  return '';
}

function edu_course_info_handler	() {
  $compass = get_compass_class();
  if (is_object($compass)) {
    $content  = '';
    if (is_page('registration')) {
      $content .= '<span>Invites you to</span>';
      $content .= '<h1>' . $compass->getCourseName() . '</h1>';
      $content .= '<span>On</span>';
      $content .= '<h1>' . $compass->getCourseDate() . '</h1>';
    }
    else if (is_page('course-feedback')) {
      $content .= '<span>Give feedback for</span>';
      $content .= '<h1>' . $compass->getCourseName() . '</h1>';
      $content .= '<span>Taught by</span>';
      $content .= '<h1>' . $compass->getCourseInstructor() . '</h1>';
    }
    return $content;
  }
  return '';
}

function edu_credit_dropdown_handler() {
  $compass = get_compass_class();
  if (is_object($compass)) {
    $content = '<select class="credit-type" id="credit-type" name="credit-type">';
    foreach ($compass->getCourseCredits() as $credit) {
      if ($credit->isApproved) {
        $today = date_create();
        if (empty($credit->expiryDate) || (!empty($credit->expiryDate) && date_create($credit->expiryDate) > $today)) {
          $content .= '<option>' . $credit->licenseType . '</option>';
        }
      }
    }
    $content .= '</select>';
    $content .= '<label class="credit-type" id="credit-type-label" for="credit-type">Credit Type</label>';
    return $content;
  }
}

function edu_hidden_inputs_handler() {
  $text = '';
  
  // get the compass related hidden elements for the client
  $compass = get_compass_class();
  if (is_object($compass)) {
    $text .= '<input type="hidden" id="session" value="' . $compass->getSessionId() . '">';
    $text .= '<input type="hidden" id="error" value="' . $compass->getError() . '">';
    $text .= '<input type="hidden" id="env" value="' . COMPASS_ENV . '">';
  }
  else {
    $text .= '<input type="hidden" id="error" value="No course provided.">';
  }
  
  // decide which stripe key to use for the JavaScript
  if (is_page('registration')) {
    $key  = '';
    if (STRIPE_TEST) {
      $key = base64_encode(get_option('edu_setting_stripe_test_publish_key'));
    }
    else {
      $key = base64_encode(get_option('edu_setting_stripe_live_publish_key'));
    }
    $text .= '<input type="hidden" id="stripeKey" value="' . $key . '">';
    $text .= '<input type="hidden" id="price" value="$' . number_format($compass->getCoursePrice(), 2) . '">';
  }
  else if (is_page('course-feedback')) {
    $participantId = 0;
    if (isset($_GET['participantID'])) {
      $participantId = $_GET['participantID'];
    }
    $text .= '<input type="hidden" id="participant" value="' . $participantId . '">';
  }
  return $text;
}

function edu_participant_registered_handler() {
  $participant = get_transient('edu_participant_class');
  if (is_object($participant)) {
    if (isset($_GET['transaction'])) {
      if ($participant->updateParticipant($_GET['transaction'])) {
        return '<div id="content" class="center bigFont">' . get_option('edu_setting_stripe_success_message') . '<div>';
      }
      else {
        return '<div id="content" class="hasError center bigFont">' . $participant->getError() . '<div>';
      }
    }
    else {
      return '<div id="content" class="center bigFont">' . get_option('edu_setting_compass_success_message') . '<div>';
    }
  }
  else {
    return '<div id="content" class="hasError center bigFont">Cannot find participant.<div>';
  }
}

function edu_feedback_success_handler() {
  return get_option('edu_setting_compass_feedback_success_message');
}

// setup the compass class
function get_compass_class() {
  delete_transient('edu_participant_class');
  $compass = get_transient('edu_compass_class');

  // get the session ID from either the POST or GET
  $sessionId = 0;
  if (isset($_GET['session'])) {
    $sessionId = $_GET['session'];
  }
  else if (isset($_POST['session'])) {
    $sessionId = $_POST['session'];
  }
  
  if ($sessionId > 0) {
    if (!is_object($compass) || $compass->getSessionId() != $sessionId) {
      $compass = new EDU_Compass_API($sessionId, COMPASS_ENV);
      if (!$compass->hasError()) {
        $compass->initialize();
        set_transient('edu_compass_class', $compass, HOUR_IN_SECONDS);
      }
    }
  }
  else {
    delete_transient('edu_compass_class');
    $compass = false;
  }
  return $compass;
}

// ajax callback functions
function edu_stripe_client_secret() {
  $key = '';
  if (STRIPE_TEST) {
    $key = get_option('edu_setting_stripe_test_secret_key');
  }
  else {
    $key = get_option('edu_setting_stripe_live_secret_key');
  }
  if (!empty($key)) {
    $compass = get_compass_class();
    $stripe = new EDU_Stripe_API($key);
    echo $stripe->createCheckoutSession($compass->getCourseName(), $compass->getCoursePrice(), $_POST['email']);
  }
  wp_die();
}

function edu_compass_register() {
  $user = array(
    'email'      => $_POST['email'],
    'name'       => $_POST['name'],
    'company'    => $_POST['company'],
    'license'    => $_POST['license'],
    'creditType' => $_POST['creditType'],
    'needCE'     => $_POST['needCE'],
  );
  $participant = new EDU_Participant_API($user, $_POST['session'], COMPASS_ENV);
  if ($participant->saveParticipant()) {
    set_transient('edu_participant_class', $participant);
  }
  else {
    echo $participant->getError();
  }
  delete_transient('edu_compass_class');
  wp_die();
}

function edu_compass_feedback() {
  $user = array(
    'participantId' => $_POST['participant'],
    'sessionId'     => $_POST['session'],
    'score'         => $_POST['score'],
    'notes'         => $_POST['notes'],
  );
  $feedback = new EDU_Feedback_API($user, COMPASS_ENV);
  if (!$feedback->saveFeedback()) {
    echo $feedback->getError();
  }
  delete_transient('edu_compass_class');
  wp_die();
}
?>
