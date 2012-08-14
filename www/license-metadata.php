<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<?php include('header.inc'); ?>
<link rel="stylesheet" type="text/css" media="screen" href="css/KelpJSONView.css" />
<script type="text/javascript" language="javascript">var license_id = "<?php print $_GET['id']; ?>";</script>
<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="js/KelpJSONView.js"></script>
<script type="text/javascript" src="js/license-metadata.js"></script>
</head>
<body>
<!-- wrap starts here -->
<div id="wrap">

   <?php include('license-header.inc'); ?>
   <div id="api-note" class="highlight"></span><strong>Note:</strong> Please feel free to load this data through our API!
     <ul>
       <?php
         $cur_uri = 'http'.(empty($_SERVER['HTTPS'])?'':'s').'://'.$_SERVER['SERVER_NAME'].$_SERVER['REQUEST_URI'];
         $api_json_uri = preg_replace('/license-metadata\.php/', 'api.php', $cur_uri);
       ?>
       <li>JSON: <a href="<?php print $api_json_uri; ?>"><?php print $api_json_uri; ?></a></li>
       <li>JSONP: <a href="<?php print $api_json_uri; ?>&callback=cbfunction"><?php print $api_json_uri; ?>&amp;callback=cbfunction</a></li>
     </ul>
   </div>

	<!-- featured starts -->	
	<div id="featured" class="clear">				
			<div id="json-wrapper"></div>
	<!-- featured ends -->
	</div>	
	
	<?php include('footer.inc'); ?>
<!-- wrap ends here -->
</div>

</body>
</html>
