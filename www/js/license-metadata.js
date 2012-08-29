$(document).ready(function(){

   // load the json directly from the api
   $.ajax({
          url: 'api.php?id=' + encodeURIComponent(license_id),
          dataType: 'json',
          success: function(data){
            // update the KelpKSONView
            jQuery.JSONView(data, $('#json-wrapper').empty());
          }
        });
 });