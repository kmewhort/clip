<?php
require_once('config.php');

// check for required inputs
if(empty($_POST['id']) || empty($_POST['json'])){
	print "Error: missing id or json data";
	exit(1);
}

// check that writing is allowed (see config.php)
if(!$ALLOW_WRITE){
	print "Error: configuration set to read-only";
	exit(1);
}

// check the file id for invalid characters 
if(preg_match('/[\/\\~]/s', $_POST['id'])){
	print "Error: invalid id";
	exit(1);
}

// if PHP magic_quotes is enabled, need to strip out the slashes
$json = get_magic_quotes_gpc() ? stripslashes($_POST['json']) : $_POST['json'];

// open the file
if(($fh = fopen($LICENSE_DIR . '/' . $_POST['id'] . '.json', 'w')) === false){
	print "Unable to write file (do you have sufficient permissions on the license data directory?).";
	exit(1);
}

// write the file
fwrite($fh, $json);
fclose($fh);

print "success";

?>
