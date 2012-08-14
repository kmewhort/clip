<?php
require_once('config.php');
require_once('clip-utils.php');

// security validation on the id/filename
$txt = load_text($LICENSE_DATA_DIR, $_GET['id'], 'json');
if(empty($txt)){
  print "Error: unknown license id.\n";
  exit(1);
}

// write out the json file as either json or jsonp
header('content-type: application/json; charset=utf-8');
if(!empty($_GET['callback']))
	print "{$_GET['callback']}(";
print $txt;
if(!empty($_GET['callback']))
	print ")";
?>