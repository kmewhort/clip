$(document).ready(function(){
    // load compatibility matrices into any placeholders
    $('.compatibility-matrix').each(function(){
        var model_id = $(this).data('compatibility-id');

        if(model_id){
            $.getScript('/compatibilities/' + model_id + '/matrix.js');
        }
    });
});