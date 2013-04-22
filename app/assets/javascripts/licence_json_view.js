//= require KelpJSONView

$(document).ready(function(){
    // load the json viewer
    $('#metadata #json-data').each(function(){
        var container = this;
        $.ajax({
            url: $(container).data('url'),
            type: 'GET',
            success: function(data, textStatus, jqXHR){
                $.JSONView(data, $(container));
            },
            dataType: 'json'
        });
    });
});