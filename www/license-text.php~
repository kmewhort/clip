<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<?php include('header.inc'); ?>
<?php require_once('config.php'); ?>
<?php require_once('clip-utils.php'); ?>
</head>
<body>
<!-- wrap starts here -->
<div id="wrap">

   <?php include('license-header.inc'); ?>
	
	<!-- featured starts -->	
	<div id="featured" class="clear license-text">
	  <div id="license-text-wrap">
	  <?php
	    $txt = load_text($LICENSE_TEXT_DIR, $_GET['id'], 'html');
       if(empty($txt)){
         print 'License text unavailable.';
         exit(1);
      }
      print $txt;
    ?>
     </div>
	<!-- featured ends -->
	</div>	
	
	<?php include('footer.inc'); ?>
<!-- wrap ends here -->
</div>

</body>
</html>
