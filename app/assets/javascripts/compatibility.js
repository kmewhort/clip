//= require foundation/modernizr.foundation.js
//= require foundation/jquery.foundation.tooltips.js

$(document).ready(function(){
    // load compatibility matrices into any placeholders
    $('#compatibility-matrix').each(function(){
        var compatibility_id = $(this).data('compatibility-id');

        if(compatibility_id && (compatibility_id != "")){
            // initialize for a particular licence
            $.getScript('/compatibilities/' + compatibility_id + '/matrix.js');
        }
        else{
            // empty matrix
            $.getScript('/compatibilities/matrix.js');
        }
    });
});

function Compatibility(){}
Compatibility.initializeMatrices = function(){
    // init tooltips
    $(document).foundationTooltips();

    // load licence selection comboboxes
    $( ".licence-select-combo" ).combobox();

    // set add-licence action
    $(".compatibility-matrix #add-licence-button").click(function(){
        var licence_ids = $.makeArray($('.compatibility-matrix .compatibility-row').map(function(){
            return $(this).children("td:first").text().replace(/(^[\s\:]+)|([\s\:]+$)/g, '');
        }));
        licence_ids.push(encodeURIComponent($('.compatibility-matrix #add-licence').val()));

        var active_row = $('.compatibility-row.active > td');
        if(active_row.length > 0){
            $.getScript('/compatibilities/' + active_row.text().replace(/(^[\s\:]+)|([\s\:]+$)/g, '') +
                        '/matrix.js?licence_ids[]=' + licence_ids.join("&licence_ids[]="));
        }
        else{
            $.getScript('/compatibilities/matrix.js?licence_ids[]=' + licence_ids.join("&licence_ids[]="));
        }
    });
}