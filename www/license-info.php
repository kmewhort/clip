<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<?php include('header.inc'); ?>
<?php require_once('clip-utils.php'); ?>
</head>
<body>
<!-- wrap starts here -->
<div id="wrap">

   <?php include('license-header.inc'); ?>
   <?php
     // retrieve the license data
     $metadata = load_json($LICENSE_DATA_DIR, $_GET['id'], 'json');
     if(empty($metadata)){
       print "Error: unknown license id.\n";
       exit(1);
     }
 
     // retrieve the scores
     $scoredata = load_json($LICENSE_SCORE_DIR, $_GET['id'], 'json');
     if(empty($scoredata)){
        print "Error: unknown license id.\n";
        exit(1);
     }
     
     // retrieve the logo, if any
     $logo = load_logo($LICENSE_LOGO_DIR , $_GET['id'], $LICENSE_LOGO_CACHE_DIR); 
     if(empty($logo))
       $logo = 'images/blank_logo.jpg';
   ?>
	
	
	<!-- featured starts -->	
	<div id="featured" class="clear">				
				
			<div class="image-block">
              <img src="<?php print $logo; ?>" alt="featured"/>
              <div class="approvals">
                 <span class="approval <?php print $metadata->is_okd_compliant ? 'approved' : 'not-approved'; ?>"><img src="images/<?php print $metadata->is_okd_compliant ? 'okfn_approved' : 'okfn_not_approved'; ?>.png"></img></span>
                 <span class="approval <?php print $metadata->is_osi_compliant ? 'approved' : 'not-approved'; ?>"><img src="images/<?php print $metadata->is_osi_compliant ? 'osi_approved' : 'osi_not_approved'; ?>.png"></img></span>
                 <span class="approval <?php print $metadata->is_dfcw_compliant ? 'approved' : 'not-approved'; ?>"><img src="images/<?php print $metadata->is_dfcw_compliant ?  'dfcw_approved' : 'dfcw_not_approved'; ?>.png"></img></span>
              </div>
         </div>
			
			<div class="text-block">
			
				<h2><a href="index.html"><?php print $metadata->title; ?></a></h2>
            <p class="post-info">CLIP/SPDX License ID: <span class="highlight"><?php print $metadata->id; ?></span></p>
            <?php
			     // compile the list of domains into a user-friendly list
     			  $domains = array();
     			  if($metadata->domain_software)
       			 $domains[] = 'software';
              if($metadata->domain_data)
                $domains[] = 'data';
              if($metadata->domain_content)
                $domains[] = 'content';
            ?>
            <p>This license is </strong> maintained by <strong><?php print $metadata->maintainer; ?></strong> for use with <?php print comma_separate($domains); ?>.
            </p>
            <table>
              <tr>
                <th colspan="4"><strong>Benchmark Summary (<a href="license-benchmarks.php?id=<?php print $metadata->id; ?>">details</a>)</strong></th>
              </tr>
              <tr>
                <td><strong>Openness score:</strong></td>
                <td><strong><?php print $scoredata->overall_score; ?> / 15</strong></td>
                <td>User legal risk mitigation:</td>
                <td><?php print $scoredata->legal_risk_score; ?> / 5.0</td>
              </tr>
              <tr>
                <td>Rights granted:</td>
                <td><?php print $scoredata->freedom_score; ?> / 5.0</td>
                <td>Business risk mitigation:</td>
                <td><?php print $scoredata->business_risk_score; ?> / 5.0</td>
              </tr>
            </table>
								
			</div>
	
	<!-- featured ends -->
	</div>	
	
	<!-- content -->
	<div id="content-outer" class="clear"><div id="content-wrap">
	
		<div id="content">
		
			<div id="left">			
			
				<div class="entry">
				
					<h3><a href="#" name="rights">Rights and Permissions</a></h3>
					<?php
     					// compile the list of covered rights into a user-friendly list
    					$rights_covered = array();
     					$rights_uncovered = array();
     					$metadata->rights->covers_copyright ? $rights_covered[] = 'Copyright' : $rights_uncovered[] = 'Copyright';
     					$metadata->rights->covers_trademarks ? $rights_covered[] = 'Trade-marks' : $rights_uncovered[] = 'Trade-marks';
     					$metadata->rights->covers_patents ? $rights_covered[] = 'Patents' : $rights_uncovered[] = 'Patents';
     					$metadata->rights->covers_neighbouring_rights ? $rights_covered[] = 'Neighbouring rights (rights in a sound recording or performance)' : $rights_uncovered[] = 'Neighbouring rights (ie. rights in a sound recording or performance)';
     					$metadata->rights->covers_sgdrs ? $rights_covered[] = 'Database rights (where applicable under European law)' : $rights_uncovered[] = 'Database rights (where applicable under European law)';
     					$metadata->rights->covers_moral_rights ? $rights_covered[] = 'Moral rights' : $rights_uncovered[] = 'Moral rights';
     				?>

					<p>You are free to:</p>
					  <ul>
					    <?php if($metadata->rights->right_to_use_and_reproduce) { ?>
					      <li id="right_to_use"><strong>Use and reproduce</strong> the work for your own purposes</li>
					    <?php } ?>
					    <?php if($metadata->rights->right_to_modify) { ?>
					      <li id="right_to_modify"><strong>Modify</strong> the work and adapt it into your own projects</li>
					    <?php } ?>
					    <?php if($metadata->rights->right_to_distribute) { ?>
					      <li id="right_to_distribute"><strong>Distribute</strong> the work and share it with others</li>
					    <?php } ?>
					  </ul>
					</p>
					<?php if(!$metadata->rights->right_to_use_and_reproduce ||
					         !$metadata->rights->right_to_modify ||
					         !$metadata->rights->right_to_distribute ||
					          $metadata->rights->prohibits_commercial_use ||
					          $metadata->rights->prohibits_tpms ||
					          $metadata->rights->prohibits_tpms_unless_parallel) {
					    ?>
					<p>However, you must <strong>NOT</strong> do any of the following:</p>
					  <ul>
					    <?php if(!$metadata->rights->right_to_use_and_reproduce) { ?>
					      <li id="no_right_to_use"><strong>Use or reproduce</strong> the work, even for your own purposes</li>
					    <?php } ?>
					    <?php if(!$metadata->rights->right_to_modify) { ?>
					      <li id="no_right_to_modify"><strong>Modify</strong> or adapt the work in any way</li>
					    <?php } ?>
					    <?php if(!$metadata->rights->right_to_distribute) { ?>
					      <li id="no_right_to_distribute"><strong>Distribute</strong> the work or share it with anyone else</li>
					    <?php } ?>
					    <?php if($metadata->rights->prohibits_commercial_use) { ?>
					      <li id="no_commercial_use">Use the work for any <strong>commercial purposes</strong></li>
					    <?php } ?>
					    <?php if($metadata->rights->prohibits_tpms) { ?>
					      <li id="no_tpms"><strong>Lock</strong> the work with any technical protection measures (TPMs) or digital rights management (DRM)</li>
					    <?php } ?>
					    <?php if($metadata->rights->prohibits_tpms_unless_parallel) { ?>
					      <li id="no_tpms_unless_parallel"><strong>Lock</strong> the work with any technical protection measures (TPMs) / digital rights management (DRM), unless you also provide an unlocked version</li>
					    <?php } ?>
					  </ul>
					</p>
					<?php } ?>
					<p>Your freedoms under this license apply to all <?php print strtolower(comma_separate($rights_covered)); ?> that vest<?php if(count($rights_covered) == 1) print 's'; ?> in the work. However, you still must ensure that you do not infringe any:
					  <ul>
					    <?php if(!empty($rights_uncovered)){
					    	 foreach($rights_uncovered as $right){
					    	   print '<li><strong>' . $right . '</strong></li>';
					    	 }
					    	} ?>
					  </ul>
					</p>
					
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
				
				</div>
				
				<div class="entry">
						
					<h3><a href="#" name="obligations">Obligations</a></h3>
					<?php if($metadata->obligations->obligation_notice ||
					         $metadata->obligations->obligation_attribution_flexible ||
					         $metadata->obligations->obligation_attribution_specific ||
					         $metadata->obligations->obligation_modifiable_form ||
					         $metadata->obligations->obligation_copyleft) {
					    ?>
					<p>You must:</p>
					<ul>
					    <?php if($metadata->obligations->obligation_notice) { ?>
					      <li id="notice_obligation"><strong>Retain the original copyright notices</strong> and disclaimers to inform downstream users of the license conditions that apply to the original work</li>
					    <?php } ?>
					    <?php if($metadata->obligations->obligation_attribution_flexible) { ?>
					      <li id="flex_attribution_obligation"><strong>Provide attribution</strong> to the original authors (you may do so in any reasonable manner appropriate to your medium)</li>
					    <?php } ?>
					    <?php if($metadata->obligations->obligation_attribution_specific && empty($metadata->obligation_attribution_specific_details)) { ?>
					      <li id="specific_attribution_obligation"><strong>Provide attribution</strong> in the exact manner specified in the license</li>
					    <?php } ?>
					    <?php if($metadata->obligations->obligation_attribution_specific && !empty($metadata->obligation_attribution_specific_details)) { ?>
					      <li id="specific_attribution_obligation">Provide attribution as follows:<br/>
					      <blockquote><?php print obligation_attribution_specific_details; ?></blockquote>
					      </li>
					    <?php } ?>
					    <?php if($metadata->obligations->obligation_modifiable_form) { ?>
					      <li id="modifiable_form_obligation">Provide the work in a <strong>modifiable form</strong> that others can easily edit and add to (eg. provide the source code of any software program)</li>
					    <?php } ?>
					    <?php if($metadata->obligations->obligation_copyleft) { ?>
					      <li id="modifiable_form_obligation"><strong>Share your modifications</strong> with others under the exact same license as the original work (for further details, see <a href="#copyleft">Share-alike / Copyleft</a> below)</li>
					    <?php } ?>
					  </ul>
					</p>
					<?php }
					else { ?>
					<p>This license imposes <strong>no major obligations</strong>.  Distribute and give others access to the work at will!
					<?php } ?>
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
				
				</div>
				
				<?php if($metadata->obligations->obligation_copyleft) {?>
				<div class="entry">
			
					<h3><a href="#" name="copyleft">Share-alike / Copyleft</a></h3>
					<?php if($metadata->copyleft->copyleft_engages_on == 'use'){ ?>
				     <p>If you <strong>use or reproduce</strong> the work in any way, you <strong>must license any changes you make to others</strong> under the same terms as the original work.</p>
				   <?php } else { ?>
					<p>You may use the work and modify it without sharing your changes, as long as this is sole for your personal use. However, to promote a community of open sharing, you <strong>must license your changes to others</strong> under the same terms as the original if you:</p>
				   <ul>
					    <?php if($metadata->copyleft->copyleft_engages_on == "distribution" || $metadata->copyleft->copyleft_engages_on == "affero") { ?>
					      <li id="no_right_to_use"><strong>Distribute</strong> or publicly communicate your modified version to anyone else, whether for free or for profit</li>
					    <?php } ?>
					    <?php if(!$metadata->copyleft->copyleft_engages_on == "affero") { ?>
					      <li id="no_right_to_use">Allow users to <strong>interact with or access</strong> your modified version of the work, whether over the internet or through another public network</li>
					    <?php } ?>
					</ul>
					<?php } ?>
					<p>This copyleft obligation applies to:</p>
					<ul>
					    <?php if($metadata->copyleft->copyleft_on == "derivatives" || $metadata->copyleft->copyleft_on == "derivatives_links_excepted"){ ?>
					      <li id="copyleft_derivative">Any <strong>adaptation or derivative work</strong> you create based on the original</li>
					    <?php } ?>
					    <?php if($metadata->copyleft->copyleft_on == "modified_files"){ ?>
					      <li id="copyleft_files">Any <strong>individual files</strong> from the original that you modify (and any of your files that include portions of the original work)</li>
					    <?php } ?>
					</ul>		
					<p>but does <strong>NOT</strong> apply to:</p>
					<ul>
					    <?php if($metadata->copyleft->copyleft_on == "derivatives_links_excepted"){ ?>
					      <li id="no_copyleft_links">A work you create that only programmatically <strong>links</strong> to an original software work</li>
					    <?php } ?>
					    <?php if($metadata->copyleft->copyleft_on == "modified_files"){ ?>
					      <li id="no_copyleft_files">Any individual <strong>files that you author</strong> entirely yourself</li>
					    <?php } ?>
					    <?php if(!($metadata->copyleft->copyleft_on == "compilation")){ ?>
					      <li id="no_copyleft_compilations">Any <strong>compilation</strong> or larger project, as long as it merely includes the whole of the unchanged original work</li>
					    <?php } ?>
					</ul>	
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>	
				</div>
				<?php } ?>
				
				<!--
				<div class="entry">
			
					<h3><a href="#" name="compatibility">Compatibility</a></h3>
					<p>			
					</p>
				
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
			
				</div>
				-->
				
				<div class="entry">
			
					<h3><a href="#" name="disclaimers">Disclaimers</a></h3>
					<?php if($metadata->disclaimers->disclaimer_warranty){ ?>
					<p>The licensor makes <strong>no guarantee</strong> to you as to:
					  <ul>
					    <li><strong>The quality of the work</strong>. Keep in mind that the work may contain inaccuracies and errors. It may be entirely unsuitable for your purpose.</li>
					    <?php if(!$metadata->disclaimers->warranty_noninfringement){ ?>
                   <li><strong>The clearance of rights</strong>. It is possible that the licensor might not actually own all of the rights that the license claims to grant. If this is the case, you could inadvertently infringe the copyright of a third party -- and you will bear the full responsibility of this infringement.</li>
                   <?php } ?>
                 </ul>
               </p>
               <?php } ?>
               <?php if($metadata->disclaimers->warranty_noninfringement) { ?>
               <p>Note that the licensor does include a "<strong>noninfringement warranty</strong>", providing a guarantee that he or she owns all of the rights which the license claims to grant.</p>
               <?php } ?>
					</p>
					<p>The license also contains a general <strong>disclaimer of liability</strong>. In most cases, you cannot sue the licensor, even if you suffer injuries or financial harm due to errors, inaccuracies, or faults on the part of the licensor.</p>
					
					<p>You must additionally <strong>indemnify</strong> the licensor for lawsuits that relate to your use of the work. That is, in certain cases, if someone else sues the licensor, it's you who must pay for all of the licensor's legal costs and any damages (even if the licensor is at fault).</p>
				
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
			
				</div>
				
				<div class="entry">
			
					<h3><a href="#" name="versioning">License versioning</a></h3>
					<?php if($metadata->license_changes->license_changes_effective_immediately){ ?>
					<p>If the licensor updates or makes any changes to the license, you are <strong>immediately bound</strong> by the new terms. You cannot keep using work under the previous license.</p>
					<?php }else { ?>
					<p>Even if the licensor releases a new version of the license with different terms, you can <strong>continue your use of the work under the original license</strong>.</p>
					<p>However, if you retrieve an updated copy of the work, it may then come under the terms of the new license.</p>
					<?php } ?>
					
					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
				</div>
				
				<div class="entry">
			
					<h3><a href="#" name="choice_of_law">Choice of Law and Forum</a></h3>
					<?php if($metadata->conflict_of_laws->forum_of == 'unspecified'){ ?>
					  <p>The license <strong>does not specify a forum</strong> for any lawsuits. If a legal dispute arises between you and the licensor, courts will decide upon the location for the hearing based on how strongly the legal issue connects to the jurisdictions involved.</p>
					<?php } else if($metadata->conflict_of_laws->forum_of == 'licensor'){ ?>
					  <p>If a legal dispute arises between you and the licensor, it must be heard by a <strong>court at the location of the licensor</strong>.  If this differs from your own location, any lawsuit may be more costly for you to launch or defend.</p>
					<?php } else if($metadata->conflict_of_laws->forum_of == 'plaintiff'){ ?>
					  <p>If a legal dispute arises between you and the licensor, it must be heard by a <strong>court at the location of the plaintiff</strong> (the person filing the lawsuit).</p>
					<?php } else if($metadata->conflict_of_laws->forum_of == 'defendant'){ ?>
					  <p>If a legal dispute arises between you and the licensor, it must be heard by a <strong>court at the location of the defendant</strong>. This can have the effect of deterring lawsuits, as it can increase the cost of a foreign would-be plaintiff filing a lawsuit.</p>
					<?php } else if($metadata->conflict_of_laws->forum_of == 'specific'){ ?>
					  <p>If a legal dispute arises between you and the licensor, it must be heard by a <strong>court at the specific location named in the license</strong> (usually within the jurisdiction of the original licensor). If this differs from your own location, any lawsuit may be more costly for you to launch or defend.</p>
					<?php } ?>
					
					<?php if($metadata->conflict_of_laws->law_of == 'unspecified'){ ?>
					  <p>The license <strong>does not specify the particular law</strong> that a court is to apply when resolving a dispute. To interpret the license, courts will determine the appropriate law based on how strongly the legal issue relates to each jurisdiction involved.</p>
					<?php } else if($metadata->conflict_of_laws->law_of == 'licensor'){ ?>
					  <p>To resolve any such legal disputes, courts will interpret the license based on the <strong>laws in force at the location of the licensor</strong>.</p>
					<?php } else if($metadata->conflict_of_laws->law_of == 'plaintiff'){ ?>
					  <p>To resolve any such legal disputes, courts will interpret the license based on the <strong>laws in force at the location of the plaintiff</strong> (the person filing the lawsuit).</p>
					<?php } else if($metadata->conflict_of_laws->law_of == 'defendant'){ ?>
					  <p>To resolve any such legal disputes, courts will interpret the license based on the <strong>laws in force at the location of the defendant</strong>.</p>
					<?php } else if($metadata->conflict_of_laws->law_of == 'forum'){ ?>
					  <p>To resolve any such legal disputes, courts will interpret the license based on the <strong>laws in force where the lawsuit is heard</strong>.</p>
					<?php } else if($metadata->conflict_of_laws->law_of == 'specific'){ ?>
					  <p>To resolve any such legal disputes, courts will interpret the license based on the <strong>laws in force at the specific location named in the license</strong>.</p>
					<?php } ?>


					<div class="help-link"><a class="more-link" href="index.html">What does this all mean?</a></div>
			
				</div>
				
			</div>
		
			<div id="right">
							
				<div class="sidemenu">	
					<h3>Go to</h3>
					<ul>				
						<li><a href="#rights">Rights and Permissions</a></li>
						<li><a href="#obligations">Obligations</a></li>
						<?php if($metadata->obligations->obligation_copyleft) {?>
						<li><a href="#copyleft">Share-alike / Copyleft</a></li>
						<?php } ?>
						<!-- <li><a href="#compatibilityl">Compatibility</a></li> -->
						<li><a href="#disclaimers">Disclaimers</a></li>
						<li><a href="#versioning">License Versioning</a></li>
						<li><a href="#choice_of_law">Choice of Law and Forum</a></li>
					</ul>	
				</div>
				
				<h3>Search</h3>
			
				<form id="quick-search" action="index.html" method="get" >
					<p>
					<label for="qsearch">Search:</label>
					<input class="tbox" id="qsearch" type="text" name="qsearch" value="type and hit enter..." title="Start typing and hit ENTER" />
					<input class="btn" alt="Search" type="image" name="searchsubmit" title="Search" src="images/search.gif" />
					</p>
				</form>	
					
			</div>		
		
		</div>	
			
	<!-- content end -->	
	</div></div>
	<?php include('footer.inc'); ?>
<!-- wrap ends here -->
</div>

</body>
</html>
