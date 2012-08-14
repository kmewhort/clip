<?php
require_once('config.php');

// load the configurations of rating weights for the different license aspects
$json = file_get_contents($WEIGHT_FILE);
$weights = json_decode($json); 
if(empty($weights)){
  print "Unable to read JSON weights file.\n";
  exit(1);
}

// calculate ratings for each license
$ratings = array();
foreach(list_licenses() as $id){
   print "Scoring license $id. ";
	$metadata = get_license_metadata($id);
	
	// calculate the rating for each category
	$ratings[$id]['freedom_score'] = rate_freedom($metadata, $weights->license_components);
	$ratings[$id]['legal_risk_score'] = rate_legal_risk($metadata, $weights->license_components);
	$ratings[$id]['business_risk_score'] = rate_business_risk($metadata, $weights->license_components);
	
	// calculate the overall rating
	$ratings[$id]['overall_score'] =
	  $ratings[$id]['freedom_score'] * $weights->categories->freedom +
	  $ratings[$id]['legal_risk_score'] * $weights->categories->legal_risk +
	  $ratings[$id]['business_risk_score'] * $weights->categories->business_risk;
	  
	print 'Overall score = ' . $ratings[$id]['overall_score'] . "\n";
}

// calculate ranking for each type of score
foreach(array('freedom', 'legal_risk', 'business_risk', 'overall') as $score_type){
	
	// get a list of the scores for this score type
	$scores = array();
	foreach($ratings as $key => $val)
	  $scores[] = $val[$score_type . '_score'];
	
	// sort by score and add ranking data
	array_multisort($scores, SORT_DESC, SORT_NUMERIC, $ratings);
	$rank = 1;
	foreach($ratings as $key => $val){
		// assign a rank
		$ratings[$key][$score_type . '_rank'] = $rank++;
		
		// now that ranking is complete, we can format the score per the configured output format
		$ratings[$key][$score_type . '_score'] =
		  sprintf($SCORE_FORMAT, $ratings[$key][$score_type . '_score']);
	}
}

// save the results
foreach($ratings as $id => $val){
	 // alphabetically sort the result data by key and convert to json
	 ksort($val);
	 $json = json_encode($val, JSON_PRETTY_PRINT);
	 
	 // write out the result
	 $filename = $LICENSE_SCORE_DIR . '/' . $id . '.json';
    if(($fh = fopen($filename, 'w')) === false){
	   print "Unable to write file ($filename).\n";
	   exit(1);
	 }
    fwrite($fh, $json);
    fclose($fh);
}

// assigns a score of the legal risk associated with a license (high score = low risk to the user)
function rate_legal_risk($license_data, $weights){

  // Choice of forum affects legal risks because of the increased legal costs of defending against a lawsuit in a foreign jurisdiction
  // -A forum selection clause (FSC) for the jurisdiction of the defendant generally introduces the lowest cost for the defendant, deterring lawsuits and legal risk
  // -An unspecified forum leaves the issue of forum up to the court to decide based on conflict of law rules, often involving considerable discretion such as with forum non conveniens considerations
  // -A FSC in favour of the licensor or pl will often bring the forum outside of the def's home jurisdictions (where this is different), introducing the highest degree of legal risk
  $forum_score = null;
  if($license_data->conflict_of_laws->forum_of == 'defendant')
    $forum_score = 1;
  else if($license_data->conflict_of_laws->forum_of == 'unspecified')
    $forum_score = 0.5;
  else if($license_data->conflict_of_laws->forum_of == 'licensor' ||
          $license_data->conflict_of_laws->forum_of == 'plaintiff' ||
          $license_data->conflict_of_laws->forum_of == 'specific')
    $forum_score = 0;
  else{
    print "Error: unknown value for conflict_of_law\n";
    exit(1);
  }
  
  // Choice of law affects legal risks because of the increased legal costs of retaining counsel and experts familiar with a foreign law
  // (it also introduces uncertainty of the legal risks in using a license where foreign legal rules may apply)
  // -A choice of law clause (CLC) for the jurisdiction of the defendant generally introduces the lowest cost for the defendant, deterring lawsuits and legal risk
  // -An unspecified CSC leaves the issue of forum up to the court to decide based on conflict of law rules, often involving considerable discretion such as with forum non conveniens considerations
  // -A CLC in favour of the licensor or pl will often bring the forum outside of the def's home jurisdictions (where this is different), introducing the highest degree of legal risk
  // -a CLC in favour of the forum which match the legal risk for the forum
  $col_score = null;
  if($license_data->conflict_of_laws->law_of == 'defendant')
    $col_score = 1;
  else if($license_data->conflict_of_laws->law_of == 'unspecified')
    $col_score = 0.5;
  else if($license_data->conflict_of_laws->law_of == 'licensor' ||
          $license_data->conflict_of_laws->law_of == 'plaintiff' ||
          $license_data->conflict_of_laws->law_of == 'specific')
    $col_score = 0;
  else if($license_data->conflict_of_laws->law_of == 'forum'){
  	 $col_score = $forum_score;
  }
  else{
    print "Error: unknown value for conflict_of_law in the following license data:\n";
    print_r($license_data);
    exit(1);
  }
  
  // The two key warranties that licensor's can provide to reduce the licensee's legal risk are 1. a warranty
  // related to quality and accuracy, such as fitness for a purpose or merchantability); and/or 2. a warranty of
  // noninfringement of copyright (and other IP)
  // -For 1, a form of this warranty is implied in many, if not most, jurisdictions.
  // -For 2, only some jurisdictions recognize an implied warranty of noninfringement.  Thus, this score is applied only
  // where such a warranty is explicitly provided and not merely where the license remains silent to this aspect. many other jurisdictions.
  $warranty_score = 0;
  if(!$license_data->disclaimers->disclaimer_warranty)
    $warranty_score += 0.5;
  if(!$license_data->disclaimers->warranty_noninfringement)
    $warranty_score += 0.5;

  // A disclaimer of liability generally prevents the licensee from making a claim against the licensor, even
  // where the licensor is legally at fault.
  $disclaimer_score = !$license_data->disclaimers->disclaimer_liability ? 1 : 0;

  // Indemnication clauses obligate the licensee to defend and/or compensate the licensor for any 3rd party
  // lawsuits against the licensor (even if the fault is attributable to the licensor)
  $indemnity_score = !$license_data->disclaimers->disclaimer_indemnity ? 1 : 0;     
    
  return
    $forum_score * $weights->choice_of_forum +
    $col_score * $weights->choice_of_law +
    $warranty_score * $weights->warranty +
    $disclaimer_score * $weights->disclaimer +
    $indemnity_score * $weights->indemnity;
}

// assigns a score of the business risk associated with a license (high score = low risk to the user)
function rate_business_risk($license_data, $weights){
  // The ability of the licensor to unilaterally change the license terms (effectively revoking the original license)
  // creates a risk that the new license terms will not be amenable to the planned or existing use case of a licensee
  $unilateral_changes = !$license_data->license_changes->license_changes_effective_immediately ? 1 : 0;
  
  // Where a license terminates on any violation of the terms, even an inadvertent breach could jeopordize
  // long-term use of the licensed content
  // -Where there is no automatic termination, damages or specific performance are generally the only remedies
  //  available (repudiation is only an option for fundamental breaches). This poses the lowest business risk.
  // -Where an automatic termination clause is attenuated by a chance to remedy a breach and automatically reinstate
  //  the license, inadvertent breaches pose less of a business risk.
  // -The right of the licensor to exercise discretion to revoke a license even where the licensee has not
  //  breached the terms poses the highest degree of business risk
  $termination = null;
  if($license_data->termination->termination_discretionary)
    $termination = 0;
  else if($license_data->termination->termination_automatic)
  	 $termination = $license_data->termination->termination_reinstatement ? 2.0/3.0 : 1.0/3.0;
  else
  	 $termination = 1.0;
  
  return
    $unilateral_changes *= $weights->unilateral_changes +
    $termination *= $weights->termination;
}

// assigns a score of the amount of freedom granted by a license (high score = more freedom);
// Note: does not deal with attempts by a license to maintain freedoms (ie. copyleft or restrictions on TPMs)
function rate_freedom($license_data, $weights){
   // With respect to data licenses, copyright is the only right that is likely to matter in most cases
   // (except in jurisdictions where SGDRs apply). This rights needs to be granted or the license
   // essentially grants nothing at all.
   if(!$license_data->rights->covers_copyright)
     return 0;
   	
	// The core rights that a license can grant and to use, modify and distribute
	$core_rights = 0;
	if($license_data->rights->right_to_use_and_reproduce)
	  $core_rights += 1.0/3.0;
	if($license_data->rights->right_to_modify)
	  $core_rights += 1.0/3.0;
	if($license_data->rights->right_to_distribute)
     $core_rights += 1.0/3.0;
     
   // The above rights may be restricted to non-commercial purposes\
   $commercial_use = !$license_data->rights->prohibits_commercial_use ? 1.0 : 0;
   
   // Notice and attribution requirements can reduce user freedom due to the burdens that complying with these
   // obligations can impose (they can become particularly problematic when combining data or content from
   // many sources)
   // -Specific attribution imposes specific wording, which may not always be feasible depending on the
   //  format (for example, a license could not necessarily comply with attribution in metadata of a large dataset)
   // -Flexible attribution generally allows a licensee to attribute (and provide notice if this is a requirement)
   //  in a manner appropriate to the medium 
   // -A mere notice requirements usually only requires a reasonably accessible URL or other notice to indicate
   //  the license that the material falls under 
  $notice_and_attribution = null;
  if($license_data->obligations->obligation_attribution_specific)
    $notice_and_attribution = 0;
  else if($license_data->obligations->obligation_attribution_flexible)
    $notice_and_attribution = 1.0 / 3.0;
  else if($license_data->obligations->obligation_notice)
    $notice_and_attribution = 2.0 / 3.0;
  else
    $notice_and_attribution = 1.0;
    
  return
    $core_rights * $weights->core_rights +
    $commercial_use * $weights->commercial_use +
    $notice_and_attribution * $weights->attribution;
}

// load the license metadata for a particular license
function get_license_metadata($id){
  global $LICENSE_DATA_DIR;

  // read the json and convert to a php object
  $json_filename = $LICENSE_DATA_DIR . '/' . $id . '.json';
  $json = file_get_contents($json_filename);
  return json_decode($json); 
  
}

// get a list of the licenses in the license dir
function list_licenses(){
  global $LICENSE_DATA_DIR;

  $ids = array();
  if($dirHandle = opendir($LICENSE_DATA_DIR)){
    while(false !== ($entry = readdir($dirHandle))){
      if(is_file($LICENSE_DATA_DIR . '/' . $entry)){
        $ids[] = substr($entry,0,-5);
      }
    }
  }
  sort($ids);
  return $ids;
}
	
?>
