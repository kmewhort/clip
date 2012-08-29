	<!--header -->
	<div id="header">			
				
		<?php include('logo.inc'); ?>
      <?php include('breadcrumbs.inc'); ?>
		<?php
		// only show navbar if we're on a page for an individual license
		if(!empty($_GET['id'])){
		?>
		<div  id="nav">
			<ul>
			   <?php if(!isset($_GET['rc'])) $_GET['rc'] = 'all'; ?>
				<li class="first"<?php print preg_match('/license\-info\.php\Z/', $_SERVER["PHP_SELF"]) ? ' id="current"' : ''; ?>><a href="license-info.php?rc=<?php print $_GET['rc']; ?>&id=<?php print urlencode($_GET['id']); ?>">License Info</a></li>
				<li <?php print preg_match('/license\-text\.php\Z/', $_SERVER["PHP_SELF"]) ? ' id="current"' : ''; ?>><a href="license-text.php?rc=<?php print $_GET['rc']; ?>&id=<?php print urlencode($_GET['id']); ?>">License Text</a></li>
				<li <?php print preg_match('/license\-benchmarks\.php\Z/', $_SERVER["PHP_SELF"]) ? ' id="current"' : ''; ?>><a href="license-benchmarks.php?rc=<?php print $_GET['rc']; ?>&id=<?php print urlencode($_GET['id']); ?>">Benchmarks</a></li>
				<li <?php print preg_match('/license\-metadata\.php\Z/', $_SERVER["PHP_SELF"]) ? ' id="current"' : ''; ?>><a href="license-metadata.php?rc=<?php print $_GET['rc']; ?>&id=<?php print urlencode($_GET['id']); ?>">Metadata</a></li>
			</ul>		
		</div>
		<?php } ?>	
						
	<!--header ends-->					
	</div>