<?php
  /* Purpose: Used for giving session feedback */
  
if (!defined('ABSPATH') ) {
	exit;
}

class EDU_Feedback_API extends EDU_Compass_API {
  private $participantId;
  private $sessionId;
  private $score;
  private $notes;
  
  function __construct($feedback, $env) {
    $this->sessionId     = $feedback['sessionId'];
    $this->participantId = $feedback['participantId'];
    $this->score         = $feedback['score'];
    $this->notes         = $feedback['notes'];
    parent::__construct($this->sessionId, $env);
  }
  
  function hasError() {
    return parent::hasError();
  }
  
  function getError() {
    return parent::getError();
  }
  
  function saveFeedback() {
    if ($this->participantId == "0") {
      parent::setError("Participant not created.");
      return !$this->hasError();
    }
    
    $feedback = array(
      'trainingID'    => $this->sessionId,
      'participantID' => $this->participantId,
      'score'         => $this->score,
      'feedback'      => $this->notes,
    );
    $data = new stdClass();
    $data->data = new stdClass();
    $data->data->trainingfeedback = array($feedback);
    $this->send('feedbackSubmit', 'doweb', json_encode($data));
    return !$this->hasError();
  }
}
?>
