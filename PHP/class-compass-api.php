<?php
/*
  Purpose: Used to call Compass to gather data
*/

if (!defined('ABSPATH') ) {
	exit;
}

class EDU_Compass_API {
  const COMPASS_BASE = 'https://{$sub}.alliantnational.com:8118/do/action/WService={$env}/{$action}?I1={$user}&I2={$pass}&I3={$param}';
  
  // set in constructor
  private $sessionId;
  private $url;
  
  // retrieved from session
  private $agentId;
  private $courseId;
  private $timeStart;
  private $price;
  private $instructor;
  
  // retrieved from course
  private $courseName;
  private $credits = array();
  
  // to capture error
  private $error;
  
  function __construct($id, $env) {
    $this->sessionId  = $id;
    
    switch ($env) {
      case 'LIVE':
        $arr = array(
          '{$sub}'  => 'compass',
          '{$env}'  => 'live',
          '{$user}' => get_option('edu_setting_compass_live_username'),
          '{$pass}' => get_option('edu_setting_compass_live_password'),
        );
        break;
      case 'BETA':
        $arr = array(
          '{$sub}'  => 'compassbeta',
          '{$env}'  => 'beta',
          '{$user}' => get_option('edu_setting_compass_beta_username'),
          '{$pass}' => get_option('edu_setting_compass_beta_password'),
        );
        break;
      case 'ALFA':
        $arr = array(
          '{$sub}'  => 'compassalfa',
          '{$env}'  => 'alfa',
          '{$user}' => get_option('edu_setting_compass_test_username'),
          '{$pass}' => get_option('edu_setting_compass_test_password'),
        );
        break;
    }
    $this->url = strtr(self::COMPASS_BASE, $arr);
  }  
  
  function initialize() {
    $response = $this->get('trainingGet&TrainingID=' . $this->sessionId, 'doweb');
    if (!$this->hasError()) {
      $response         = $this->parse($response);
      $training         = $response->data->training[0];
      $this->instructor = $training->instructorName;
      $this->courseId   = $training->courseID;
      $this->agentId    = $training->agentID;
      $this->price      = $training->cost;
      $this->timeStart  = date_create($training->timeStart);
      if (isset($this->courseId)) {
        $response = $this->get('courseGet&courseID=' . $this->courseId, 'doweb');
        if (!$this->hasError()) {
          $response = $this->parse($response);
          $course = $response->data->course[0];
          $this->courseName  = $course->name;
          if ($course->coursecredit) {
            foreach ($course->coursecredit as $item) {
              $this->credits[] = $item;
            }
          }
        }
      }
    }
  }
  
  function getAgentLogoOrName() {
    if (isset($this->agentId)) {
      $response = $this->get('agentlogoGet&agentID=' . $this->agentId, 'do');
      if (!$this->hasError()) {
        $response = $this->parse($response);
        if (empty($response->data->Image->lcValue)) {
          $response = $this->get('agentsGet&agentID=' . $this->agentId, 'act');
          if (!$this->hasError()) {
            $response = $this->parse($response);
            return $response->Body->dataset->Agent[0]['Legalname'];
          }
        }
        else {
          return '<img src="data:image/jpeg;base64,' . $response->data->Image->lcValue . '">';
        }
      }
    }
    return '';
  }
  
  function hasError() {
    return !empty($this->getError());
  }
  
  function getError() {
    return $this->error;
  }
  
  function setError($msg) {
    $this->error = $msg;
  }
  
  function getCourseName() {
    return $this->courseName;
  }
  
  function getCoursePrice() {
    return $this->price;
  }
  
  function getCourseDate() {
    if (!empty($this->timeStart)) {
      return date_format($this->timeStart, 'l, F j @ g:i A');
    }
    return '';
  }
  
  function getCourseInstructor() {
    return $this->instructor;
  }
  
  function getSessionId() {
    return $this->sessionId;
  }
  
  function getCourseCredits() {
    return $this->credits;
  }
  
  protected function get($param, $type) {
    $url = strtr($this->url, array('{$action}' => $type, '{$param}' => $param));
    $response = wp_remote_get(
      $url,
      array(
        'timeout' => 70,
      )
    );
    
    // check for a wordpress error
    if (is_wp_error($response)) {
      $this->error = $response->get_error_message();
      return false;
    }
    
    // Compass error
    if(wp_remote_retrieve_header($response, 'X-Compass') === 'F'){
      $this->error = wp_remote_retrieve_header($response, 'X-CompassMsg');  
      return false;
    }
    
    return $response;
  }
  
  protected function send($param, $type, $data) {
    $url = strtr($this->url, array('{$action}' => $type, '{$param}' => $param));
    $response = wp_remote_post(
      $url,
      array(
        'headers'     => array('Content-Type' => 'application/json; charset=utf-8'),
        'body'        => $data,
        'timeout'     => 70,
        'data_format' => 'body'
      )
    );
    
    // check for a wordpress error
    if (is_wp_error($response)) {
      $this->error = $response->get_error_message();
      return false;
    }
    
    // Compass error
    if(wp_remote_retrieve_header($response, 'X-Compass') === 'F'){
      $this->error = wp_remote_retrieve_header($response, 'X-CompassMsg');  
      return false;
    }
    
    return $response;
  }
  
  protected function parse($response) {
    $parsed_response = json_decode($response['body']);
    if (!isset($parsed_response)){
      $parsed_response = simplexml_load_string($response['body']);
    }
    return $parsed_response;
  }
}
?>
