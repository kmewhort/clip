<?php
/* This tool scrapes the license list from SPDX (Software Package Data Exchange) to download the full name, identifier, whether OSI approved, and license text for the SPDX list of licenses. */

require_once('lib/simple_html_dom.php');
require_once('config.php');

// grab the license list
$root_url = 'http://spdx.org/licenses/';
$html = file_get_html($root_url);

// parse each license
$rows = $html->find('table tr');
for($i = 1; $i < count($rows); $i++){
 $data = array();
 $tr = $rows[$i];

 // get the id and check if this license metadata already exists
 $data['id'] = trim($tr->children(1)->plaintext);
 if(empty($data['id'])){
   print($i . '. Row has no license id.' . "\n");
 }
 if(!$OVERWRITE_EXISTING && file_exists($LICENSE_JSON_DIR . '/' . $data['id'] . '.json')){
   print($i . '. ' . $data['id'] . ': Data already exists. Nothing written.' . "\n");
   continue;
 }
  
 // rest of data from the table row
 $data['title'] = trim($tr->children(0)->plaintext);
 $data['is_osi_compliant'] = $tr->children(2)->plaintext == 'Y' ? true : false;
 
 // drill down to the license page itself
 $page_url = $root_url . $tr->children(0)->find('a', 0)->href; 
 $page_html = file_get_html($page_url);
 
 // get the original license url ('Other web pages for this license')
 $link_elem = $page_html->find('a[rel="owl:sameAs"]', 0);
 if($link_elem)
   $data['url'] = $link_elem->href; 
 
 // check whether the license has been superceded (stated in the Notes section)
 $notes_h_elem = $page_html->find('#notes', 0);
 if($notes_h_elem){
   $notes_elem = $notes_h_elem->next_sibling();
   $notes_txt = $notes_elem->plaintext; 
   $data['status'] = preg_match('/has been superseded/', $notes_txt) ? 'inactive' : 'active';
 }

 // get the full license text
 $text = $page_html->find('.license-text',0)->plaintext;

 // write out the data and license text
 $json_fh = fopen($LICENSE_JSON_DIR . '/' . $data['id'] . '.json', 'w');
 fwrite($json_fh, json_encode($data, JSON_PRETTY_PRINT));
 fclose($json_fh);

 $txt_fh = fopen($LICENSE_TEXT_DIR . '/' . $data['id'] . '.txt', 'w');
 fwrite($txt_fh, html_entity_decode($text));
 fclose($txt_fh);

 print($i . '. ' . $data['id'] . ': License data and text written.' . "\n");
}
?>
  
