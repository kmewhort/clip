<?php
/* This script contains loaders for the licensing data */
require_once('config.php');

// load a json file
function load_json($dir, $base_filename, $ext){
  $json = load_text($dir, $base_filename, $ext);
  if(empty($json))
    return false;

  return json_decode($json);
}

// load a text file
function load_text($dir, $base_filename, $ext){
  // security validation on the filename
  if(preg_match('/[^A-Za-z0-9\-\_\.\+]/', $base_filename))
    return false;
    
  // check that the file exists
  $filename = $dir . '/' . $base_filename . '.' . $ext;
  if(!file_exists($filename))
    return false;

  // load the text
  $text = file_get_contents($filename);
  if(empty($text))
    return false;
  
  return $text;
}

// load a logo
function load_logo($dir, $base_filename, $cache_dir, $overwrite_cache = false){
  // security validation on the filename
  if(preg_match('/[^A-Za-z0-9\-\_\.\+]/', $base_filename))
    return false;

  // check if a processed logo is already cached
  $cache_filename = $cache_dir . '/' . $base_filename . '.cache.jpg';
  if(!$overwrite_cache && file_exists($cache_filename))
    return $cache_filename;
  
  // otherwise, check if an unprocessed logo exists
  $image_filename = null;
  foreach(array('.jpg', '.png', '.gif', '.bmp') as $ext){
    $filename = $dir . '/' . $base_filename . $ext;
    if(file_exists($filename))
  	    $image_filename = $filename;
  }
  if(!$image_filename)
    return false;
    
  // process the logo into a 250x250 image
  $output_filename = $cache_dir;
  $image = new Imagick($image_filename);
  $image->thumbnailImage(220,220, true);
  $borderWidth = abs(round(($image->getImageWidth() - 220) /2)) + 15;
  $borderHeight = abs(round(($image->getImageHeight() - 220) /2)) + 15;
  $image->borderImage(new ImagickPixel("rgb(255,255,255)"), $borderWidth, $borderHeight);
  $image->writeImage($cache_filename);
  return $cache_filename;
}

// load a score file in Google Charts format
function load_scores($dir, $base_filename, $cache_dir, $overwrite_cache = true){
  // security validation on the filename
  if(preg_match('/[^A-Za-z0-9\-\_\.\+]/', $base_filename))
    return false;

  // check if a processed score file is already cached
  $cache_filename = $cache_dir . '/' . $base_filename . '.score.cache.json';
  if(!$overwrite_cache && file_exists($cache_filename))
    return $cache_filename;
    
  // load the raw json
  $json = load_json($dir, $base_filename, 'json');
  if(empty($json)){
    return false;
  }
    
  // process the score file into google format
  $data = new stdClass;
  $data->cols = array();
  $data->cols[] = (object) array('id' => 'measure', 'label' => 'Measure', 'type' => 'string');
  $data->cols[] = (object) array('id' => 'value', 'label' => 'Value', 'type' => 'number');
      
  foreach($json as $key => $val){
  	 $label_cell = (object) array('v' => $key);
  	 $value_cell = (object) array('v' => (double)$val);
  	 $data->rows[] = (object) array('c' => array($label_cell, $value_cell));
  }
  
  // write out the json
  $google_json = json_encode($data);
  file_put_contents($cache_filename, $google_json);
  return $cache_filename;
}

// load the benchmarks for a group of licenses
// -$licenses is a 2d array of different groups of licenses
function load_benchmarks($licenses, $base_filename, $cache_dir, $overwrite_cache = true){
  global $LICENSE_SCORE_DIR, $LICENSE_DATA_DIR;
	
  // security validation on the filename
  if(preg_match('/[^A-Za-z0-9\-\_\.\+]/', $base_filename))
    return false;

  // check if a processed benchmark file is already cached
  $cache_filename = $cache_dir . '/' . $base_filename . '.benchmark.cache.json';
  if(!$overwrite_cache && file_exists($cache_filename))
    return $cache_filename;
    
  // setup the data columns for each group of licenses (each group gets its own columns so it can
  // have its own color)
  $data = new stdClass;
  $data->cols = array();
  $data->cols[] = (object) array('id' => 'license_id', 'label' => 'License', 'type' => 'string');
  $data->cols[] = (object) array('id' => 'license_label', 'label' => 'License', 'type' => 'string');
  $data->cols[] = (object) array('id' => 'tooltip', 'role' => 'tooltip', 'type' => 'string', 'p' => (object)array("role" => 'tooltip'));
  for($groupId = -1; $groupId < count($licenses); $groupId++){
  	 $precursor = ($groupId == -1) ? 'all-' : "$groupId-";
  	 
    // setup the data columns in google format
    $data->cols[] = (object) array('id' => $precursor . 'openness_score', 'label' => 'Overall Openness', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'openness_rank', 'label' => 'Openness Rank', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_freedom_score', 'label' => 'Rights Granted', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_freedom_rank', 'label' => 'Rights Granted Rank', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_legal_risk_score', 'label' => 'Legal Risk', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_legal_risk_rank', 'label' => 'Legal Risk Rank', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_business_risk_score', 'label' => 'Business Risk', 'type' => 'number');
    $data->cols[] = (object) array('id' => $precursor . 'user_business_risk_rank', 'label' => 'Business Risk Rank', 'type' => 'number');
  }

  // setup the rows for each group of licenses  
  $data->rows = array();
  for($groupId = 0; $groupId < count($licenses); $groupId++){

  	 // for each license
    foreach($licenses[$groupId] as $id){
  	    // load the raw score json
      $json = load_json($LICENSE_SCORE_DIR, $id, 'json');
      if(empty($json)){
        return false;
      }

      // for each column
      $row = array();
      foreach($data->cols as $col){
        // load the license data
        $license_data = load_json($LICENSE_DATA_DIR, $id, 'json');
        
        // always fill in the license id column
  	     if($col->id == 'license_id'){
  	   	  $row[] = (object) array('v' => $id);
  	     }
        // always fill in the license name column
  	     else if($col->id == 'license_label'){
  	     	  $license_name = $id;
  	     	  // for Canadian government licenses, grab the maintainer name as a nicer label
  	     	  if(preg_match('/\ACAN\-/', $id)){
  	     	  	  if($license_data->maintainer != null){
  	     	  	  	  $license_name = $license_data->maintainer;
  	     	  	  }
  	     	  }
  	   	  $row[] = (object) array('v' => $license_name);
  	     }
  	     // always fill in the tooltip column
  	     else if($col->id == 'tooltip'){
  	     	  $tip = $license_data->title;
  	   	  $row[] = (object) array('v' => $tip);
  	     }
  	     else{
  	     	  // parse back out the group id and column id
  	     	  if(!preg_match("/(\d+)\-(.+)/", $col->id, $matches))
  	     	    preg_match("/(all)\-(.+)/", $col->id, $matches);
  	        $col_group = $matches[1];
  	        $col_id = $matches[2];

           // if the group matches or this colum is the 'all' group, set the data
  	        if($col_group == $groupId || $col_group == 'all')
  	   	    $row[] = (object) array('v' => (double)$json->$col_id);
  	   	  // otherwise, set the data to null
  	   	  else 
  	          $row[] = (object) array('v' => null);
  	      }
  	   }
  	   $data->rows[] = (object) array('c' => $row);
   }
  }

  // write out the json
  $google_json = json_encode($data);
  file_put_contents($cache_filename, $google_json);
  return $cache_filename;
}


// list of all licenses
function license_list(){
	global $LICENSE_DATA_DIR;
	$ids = array();
	if($dirHandle = opendir($LICENSE_DATA_DIR)){
	  while(false !== ($entry = readdir($dirHandle))){
		if(is_file($LICENSE_DATA_DIR . '/' . $entry)){
			$ids[] = substr($entry,0,-5);
		}
	  }
	}
	return $ids;
}

// create a comma-seperated list with an 'and' in between
function comma_separate($items){
  if(count($items) <= 1)
    return '<strong>' . $items[0] . '</strong>';
  if(count($items) <= 2)
    return '<strong>' . $items[0] . '</strong> and <strong>' . $items[1] . '</strong>';
  
  return strtolower('<strong>' . implode('</strong>, <strong>', array_slice($items, 0, -2)) . '</strong>, ' .
    '<strong>' . $items[count($items)-2] . '</strong> and <strong>' .
    $items[count($items)-1] . '</strong>');
}

// snippet from http://www.talkphp.com/tips-tricks/204-tutorial-getting-th-st-rd-ordinal-suffixes-numbers-dates.html
function get_ordinal($num) {
    // first convert to string if needed
    $the_num = (string) $num;
    // now we grab the last digit of the number
    $last_digit = substr($the_num, -1, 1);
    // if the string is more than 2 chars long, we get
    // the second to last character to evaluate
    if (strlen($the_num)>1) {
        $next_to_last = substr($the_num, -2, 1);
    } else {
        $next_to_last = "";
    }
    // now iterate through possibilities in a switch
    switch($last_digit) {
        case "1":
            // testing the second from last digit here
            switch($next_to_last) {
                case "1":
                    $the_num.="th";
                    break;
                default:
                    $the_num.="st";
            }
            break;
        case "2":
            // testing the second from last digit here
            switch($next_to_last) {
                case "1":
                    $the_num.="th";
                    break;
                default:
                    $the_num.="nd";
            }
            break;
        // if last digit is a 3
        case "3":
            // testing the second from last digit here
            switch($next_to_last) {
                case "1":
                    $the_num.="th";
                    break;
                default:
                    $the_num.="rd";
            }
            break;
        // for all the other numbers we use "th"
        default:
            $the_num.="th";
    }

    // finally, return our string with it's new suffix
    return $the_num;
}
?>