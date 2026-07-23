<?php
  /* Purpose: Used for saving a participant */
  
if (!defined('ABSPATH') ) {
	exit;
}

class EDU_Participant_API extends EDU_Compass_API {
  private $participantId;
  private $email;
  private $name;
  private $company;
  private $license;
  private $creditType;
  private $needCE;
  
  function __construct($user, $id, $env) {
    $this->email      = $user['email'];
    $this->name       = $user['name'];
    $this->company    = $user['company'];
    $this->license    = $user['license'];
    $this->creditType = $user['creditType'];
    $this->needCE     = $user['needCE'];
    parent::__construct($id, $env);
  }
  
  function hasError() {
    return parent::hasError();
  }
  
  function getError() {
    return parent::getError();
  }
  
  function updateParticipant($transaction) {
    $participant = array(
      'email'       => $this->email,
      'name'        => $this->name,
      'company'     => $this->company,
      'license'     => $this->license,
      'needCE'      => true,
      'hasPaid'     => true,
      'paymentID'   => $transaction,
      'LicenseType' => $this->creditType,
    );
    $data = new stdClass();
    $data->data = new stdClass();
    $data->data->participant = array($participant);
    $this->send('participantModify&ParticipantID=' . $this->participantId, 'doweb', json_encode($data));
    return !$this->hasError();
  }
  
  function saveParticipant() {
    $participant = array(
      'email'       => $this->email,
      'name'        => $this->name,
      'company'     => $this->company,
      'license'     => $this->license,
      'hasPaid'     => false,
      'paymentID'   => '',
      'LicenseType' => $this->creditType,
    );
    $data = new stdClass();
    $data->data = new stdClass();
    $data->data->participant = array($participant);
    $response = $this->send('participantRegister&trainingID=' . $this->getSessionId(), 'doweb', json_encode($data));
    if (!$this->hasError()) {
      $response = $this->parse($response);
      $this->participantId = $response->data->participant[0]->participantID;
    }
    return !$this->hasError();
  }
}
?>
