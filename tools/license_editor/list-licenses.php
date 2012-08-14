<?php
require_once('config.php');

// output a list of the license ids (based on the json files in the licenses directory)
$ids = array();
if($dirHandle = opendir($LICENSE_DIR)){
	while(false !== ($entry = readdir($dirHandle))){
		if(is_file($LICENSE_DIR . '/' . $entry)){
			$ids[] = substr($entry,0,-5);
		}
	}
}
sort($ids);
	
header('Content-Type: text/javascript');
echo json_encode($ids); 
?>
