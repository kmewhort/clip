$(document).ready(function(){
   // disable ajax caching
   $.ajaxSetup({ cache: false });

   // watch for any changes to the copyleft obligations and toggle the details on/off
   toggle_copyleft_details();
   $('input[name="obligation_copyleft"]').change(toggle_copyleft_details);
   
   // watch for any changes to a form value and immediately update the preview
   $('#license_fields input').change(function(){
      // convert the form to json 
      var json = form_to_json($(this).closest('form'));
      jQuery.JSONView(json, $('#json').empty());
   });

   // display the initial json when the page is ready
   clear_form($('#license_fields form'));
   var json = form_to_json($('#license_fields form'));
   jQuery.JSONView(json, $('#json').empty());

   // load the list of licenses
   populate_license_list($('#license_selection'));

   // upon the selection of a different license, load the appropriate json file
   $('#license_selection').change(function(){
     // get the id from the select box
     var licenseId = $('#license_selection').val();
     if(licenseId != '-new-'){
       $.ajax({
          url: '../../license_info/metadata/' + licenseId + '.json',
          dataType: 'json',
          success: function(data){
            // clear the form
            clear_form($('#license_fields form'));

            // fill in the form with the new data
            json_to_form(data, $('#basic_info'));
            toggle_copyleft_details();
       
            // update the json preview
            jQuery.JSONView(data, $('#json').empty());
          }
        });
     }
   });
   
   // disable the save button if modifications are not permitted
    $.ajax({
          url: 'is_writeable.php',
          success: function(result){
             $('#save').attr('disabled', !result);
          }
   });

   // register the save button to save any changes to the json file
   $('#save').click(function(){
       // get the short id (which is also the filename)
       var id = $('input[name="id"]').val();
      
       // get the json data
       var jsonStr = JSON.stringify(form_to_json($('#license_fields form')),
	null, 2);
  
       // save the data
       $.ajax({
           type: 'POST',
           url: 'save-license.php',
           data: {
               'id': id,
               'json': jsonStr },
           success: function(data){
               if(data != 'success')
                 alert(data);
           },
       });
       
       // reload the license list
       populate_license_list($('#license_selection'));
       
       // re-select the current (or new) option
       $('#license_selection').ready(function(){
         $('#license_selection').val(id);});
   }); 
 
   // watch for any changes to the copyleft obligations and toggle the details on/off
   toggle_copyleft_details();
   $('input[name="obligation_copyleft"]').change(toggle_copyleft_details);
});


/* convert the license data form to the appropriate json format */
function form_to_json(form){
  // the key/value pairs in the basic licensing info live in the root json object
  var jsonData = serializeFormData($('fieldset#basic_info', form));

  // add each other fieldset in its own object
  $('fieldset:not(#basic_info)', form).each(function(){
     jsonData[this.id] = serializeFormData(this);
  });
  
  return jsonData;
}

/* serialize form data to a object of key/value pairs; note that
 * checkboxes are returned as boolean values */
function serializeFormData(form){
  var data = new Object();
  $('input', form)
	.filter(function(){
		return (this.name && !this.disabled);
	})
	.each(function(){
		var val = this.value;
		// convert checkboxes to booleans
		if(this.type == 'checkbox'){
			val = this.checked;
		}
                // only set value of a radio if its checked
                else if(this.type == 'radio'){
			if(!this.checked)
				val = null;
		}
                if(val != null)
		    data[this.name] = val;
	});
  return data; 
}

/* populate the license data form based on json input */
function json_to_form(jsonData, form){
  // for each data element
  for(var key in jsonData){
    var val = jsonData[key];
    
    // if the element is a sub-object with its own properties, recurse
    if($.isPlainObject(val))
      json_to_form(val, form);
                       
    // find the element in the form and set it
    $('input[name='+key+']').each(function(){
      // if the form input is a checkbox, check it if the value is true
      if(this.type == 'checkbox'){
         this.checked = val;
      }
      // if the form input is a radio, only check the matching value
      else if(this.type == 'radio'){
         if(this.value == val)
            this.checked = true;
      }
      // else, set the value to match
      else{
         this.value = val;
      }
    }); 
  }
}

/* clear the form */
function clear_form(form){
   $('input', form).each(function(){
     if(this.type == 'radio' || this.type == 'checkbox')
       this.checked = false;
     else
       this.value = "";
   });
}

/* populate a select list with the list of licenses */
function populate_license_list(select){
   // load the list of licenses
   $.ajax({
	url: 'list-licenses.php',
	dataType: 'json',
	success: function(data){
		select.empty();
		// add an option to add a new license
      select.append(
      	$('<option></option>').attr('value', '-new-').text('New...'));
      // add each existing license
	   for(i in data){
	     select.append(
			$('<option></option>').attr('value',data[i]).text(data[i]));
		}
	}
   });
} 

/* toggle copyleft details depending on whether the copyleft obligation is checked */
function toggle_copyleft_details(){
  var details_on = $('input[name="obligation_copyleft"]').get(0).checked;

  //enable/disable radios
  $('fieldset#copyleft input').each(function(){
      if(!details_on){
        this.checked = false;
        $('#copyleft').css('color', '#888');
      }
      else{
        $('#copyleft').css('color', 'inherit');
      }
      this.disabled = !details_on;
  });
  //enable/disable "copyleft obligations compatible with" fields
  $('#sublicensing input[name*="copyleft"]').each(function(){
      if(!details_on){
        this.checked = false;
      }
      this.disabled = !details_on;
  });
}

