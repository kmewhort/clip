//= require KelpJSONView

function get_json_preview(){
    $.ajax({
      type: 'POST',
      url: 'preview',
      data: $('.licences form').serialize(),
      success: function(data, textStatus, jqXHR){
          $.JSONView(data, $('#json-preview').empty());
      },
      dataType: 'json'
    });
}

// toggle attribution fields
function attribution_toggle(){
    if($(this).prop('checked')){
        $('.attribution, .attribution textarea, .attribution input').prop('disabled', false);
    }
    else{
        $('.attribution, .attribution textarea, .attribution input').prop('disabled', true);
    }
}

// toggle copyleft fields
function copyleft_toggle(){
    if($(this).prop('checked')){
        $('.copyleft, .copyleft input').prop('disabled', false);
    }
    else{
        $('.copyleft, .copyleft input').prop('disabled', true);
    }
}

// toggle patent licence fields
function patent_licence_toggle(){
    if($(this).prop('checked')){
        $('.patents .patent-licence-extends-to input').prop('disabled', false);
    }
    else{
        $('.patents .patent-licence-extends-to input').prop('disabled', true);
    }
}

// toggle patent retaliation fields
function patent_retaliation_toggle(){
    if($(this).prop('checked')){
        $('.patents .patent-retaliation input, .patents .patent-retaliation-engages-upon input').prop('disabled', false);
    }
    else{
        $('.patents .patent-retaliation input, .patents .patent-retaliation-engages-upon input').prop('disabled', true);
    }
}

// register on-change events
$(document).ready(function(){
    // conditional fields
    $('#licence_obligation_obligation_attribution').change(attribution_toggle).change();
    $('#licence_obligation_obligation_copyleft').change(copyleft_toggle).change();
    $('#licence_right_covers_patents_explicitly').change(patent_licence_toggle).change();
    $('#licence_right_prohibits_patent_actions').change(patent_retaliation_toggle).change();

    // json preview update
    $('.licences input, .licences textarea').change(get_json_preview);
    get_json_preview();
});

