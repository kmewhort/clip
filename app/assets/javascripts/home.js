//= require jquery.ui.combobox
$(function() {
    $( "#licence-search-combobox" ).combobox();
    $( "#licence-search-combobox" ).on("comboboxselected", function(event,ui){
        location.href = '/licences/' + $(ui.item).attr('value');
    });
});