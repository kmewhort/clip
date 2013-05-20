//= require licence_select
$(function() {
    $( ".home #licence-search-combobox" ).on("comboboxselected", function(event,ui){
        location.href = '/licences/' + $(ui.item).attr('value');
    });
});