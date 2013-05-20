$(document).ready(function(){
    // load compatibility matrices into any placeholders
    $('.compatibility-matrix').each(function(){
        var compatibility_id = $(this).data('compatibility-id');

        if(compatibility_id){
            $.getScript('/compatibilities/' + compatibility_id + '/matrix.js');
        }
    });
});