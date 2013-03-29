//= require jquery.ui.combobox
$(function() {
    $( ".home #licence-search-combobox" ).combobox().on("comboboxselected", function(event,ui){
        location.href = '/licences/' + $(ui.item).attr('value');
    });
});