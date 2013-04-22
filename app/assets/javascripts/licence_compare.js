/*
 *= require jquery.ui.combobox
 */
$(document).ready(function(){
   new LicenceCompare();
});

function LicenceCompare(){
    var that = this;
    // render licence selection comboboxes (loading licence comparison when two licences are selected)
    $( ".licence-select-combo" ).combobox().on("comboboxselected", function(event,ui){
        licence_a = $('#licence-select-a').val();
        licence_b = $('#licence-select-b').val();
        that.compareLicences(licence_a, licence_b);
    });
}

LicenceCompare.prototype.compareLicences = function(licence_a_id, licence_b_id){
    if(licence_a && licence_b){
        // wait spinner
        $('#licence-diff').empty().append("Loading...").append($("<div>").addClass('wait'));

        // refresh the container
        var compare_url = '/licences/' + licence_a + '/compare_to.js?licence_id=' + licence_b;
        if($('#licence-select-wrapper-a').length > 0)
          compare_url += '&selectable=1';
        $.getScript(compare_url);

    }
}
