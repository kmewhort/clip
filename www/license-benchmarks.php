<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<script type='text/javascript' src='https://www.google.com/jsapi'></script>
<script type='text/javascript'>
  google.load('visualization', '1', {packages:['gauge','corechart']});
</script>
<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="js/license-benchmarks.js"></script>
<?php require_once('clip-utils.php'); ?>
<?php include('header.inc'); ?>
<?php 
     // retrieve the scores
     $scoredata = load_json($LICENSE_SCORE_DIR, $_GET['id'], 'json');
     if(empty($scoredata)){
        print "Error: unknown license id.\n";
        exit(1);
     }
?>
</head>
<body>
<!-- wrap starts here -->
<div id="wrap">

   <?php include('license-header.inc'); ?>
   
	<!-- featured starts -->	
	<div id="featured" class="clear">
		<?php
		  // load the scores in Google Charts format
		  $score_filename = load_scores($LICENSE_SCORE_DIR, $_GET['id'], $LICENSE_SCORE_CACHE_DIR);
     	  if(empty($score_filename)){
           print "Error: unknown license id.\n";
           exit(1);
        }	
      ?>
      <div id="benchmark-feature-text">
	     <p>This license achieves an overall openness benchmark of <strong><?php print $scoredata->overall_score; ?></strong>.  This ranks it <strong><?php print get_ordinal($scoredata->overall_rank); ?></strong> out of all licenses in our database.</p>
	     <p>This score reflects the license's ability to provide the user/licensee with a flexible and friendly license, based on (1) the <strong>rights and freedoms</strong> granted, (2) the <strong>legal risks</strong> posed, and (3) the <strong>business risks</strong> posed.</p>
	   </div>	
		<div id="benchmark-gauges" class="benchmark-gauges" data-file="<?php print $score_filename; ?>">
		  <span class="gauge-wrapper">
		    <span class="gauge-label-short">Overall</span>
		    <span class="benchmark-gauge" data-col="overall_score" data-yellow="8.5" data-green="12" data-max="15"></span>
		  </span>
		  <span class="gauge-wrapper">
		    <span class="gauge-label-short">Rights Granted</span>
		    <span class="benchmark-gauge" data-col="freedom_score" data-yellow="3" data-green="4" data-max="5"></span>
		  </span>
		  <span class="gauge-wrapper">
		    <span class="gauge-label">Legal Risk<br />Mitigation</span>
		    <span class="benchmark-gauge" data-col="legal_risk_score" data-yellow="3" data-green="4" data-max="5"></span>
		  </span>
		  <span class="gauge-wrapper">
		    <span class="gauge-label">Business Risk<br />Mitigation</span>
		    <span class="benchmark-gauge" data-col="business_risk_score" data-yellow="3" data-green="4" data-max="5"></span>
		  </span>
		</div>
		
		<?php
		  // if the license is a Canadian government license, show a benchmark chart for this category
		  if(preg_match('/\ACAN\-/', $_GET['id'])){
		  	  // generate a list of canadian licenses to include in the benchmark
		  	  $can_licenses = array();
		  	  foreach(license_list() as $id){
		  	  	  if(preg_match('/\ACAN\-/', $id) && $id != $_GET['id'])
		  	  	    $can_licenses[] = $id;
		  	  }
		  	  
		  	  // also include PDDL, CC0 and CC-BY in the benchmarks
		  	  $compare_licenses = array('ODC-PDDL-1.0', 'CC0-1.0','CC-BY-3.0'); 

		  	  // add this license in its own color
  	  	     $this_license = array($_GET['id']);
		  	  
		  	  // load the Canada benchmarks in Google Charts format
		  	  $canada_filename = load_benchmarks(array($can_licenses, $compare_licenses, $this_license), $_GET['id'], $LICENSE_SCORE_CACHE_DIR);
     	     if(empty($canada_filename)){
             print "Error generating benchmarks\n";
             exit(1);
           }
		?>
		<div class="benchmark-chart"
		  data-file="<?php print $canada_filename; ?>"
		  data-cols="0-overall_score,1-overall_score,2-overall_score"
		  data-sortby="all-overall_score"
		  data-title="Canadian Data License Benchmark Scores"></div>
		<?php } ?>
	<!-- featured ends -->
	</div>	

	<!-- content -->
	<div id="content-outer" class="clear"><div id="content-wrap">
	
		<div id="content">
		
			<div id="left">			
			
				<div class="entry">
				<h3>Rights Granted Benchmark</h3>
				<h3>Legal Risk Benchmark</h3>
				<h3>Business Risk Benchmark</h3>
				</div>
			</div>
		</div>
	</div>
	
	<?php include('footer.inc'); ?>
<!-- wrap ends here -->
</div>

</body>
</html>
