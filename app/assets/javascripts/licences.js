//= require KelpJSONView
var LicenceEdit = new Array();

// preview json for the edit form
LicenceEdit.get_json_preview = function(){
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
LicenceEdit.attribution_toggle = function(){
    if($(this).prop('checked')){
        $('.attribution, .attribution textarea, .attribution input').prop('disabled', false);
    }
    else{
        $('.attribution, .attribution textarea, .attribution input').prop('disabled', true);
    }
}

// toggle copyleft fields
LicenceEdit.copyleft_toggle = function(){
    if($(this).prop('checked')){
        $('.copyleft, .copyleft input').prop('disabled', false);
    }
    else{
        $('.copyleft, .copyleft input').prop('disabled', true);
    }
}

// toggle patent licence fields
LicenceEdit.patent_licence_toggle = function(){
    if($(this).prop('checked')){
        $('.patents .patent-licence-extends-to input').prop('disabled', false);
    }
    else{
        $('.patents .patent-licence-extends-to input').prop('disabled', true);
    }
}

// toggle patent retaliation fields
LicenceEdit.patent_retaliation_toggle = function(){
    if($(this).prop('checked')){
        $('.patents .patent-retaliation input, .patents .patent-retaliation-engages-upon input').prop('disabled', false);
    }
    else{
        $('.patents .patent-retaliation input, .patents .patent-retaliation-engages-upon input').prop('disabled', true);
    }
}

// register on-change events
$(document).ready(function(){
    // conditional fields in licence editing
    $('#licence_obligation_obligation_attribution').change(LicenceEdit.attribution_toggle).change();
    $('#licence_obligation_obligation_copyleft').change(LicenceEdit.copyleft_toggle).change();
    $('#licence_right_covers_patents_explicitly').change(LicenceEdit.patent_licence_toggle).change();
    $('#licence_right_prohibits_patent_actions').change(LicenceEdit.patent_retaliation_toggle).change();

    // update licence editor json preview
    $('.licences input, .licences textarea').change(LicenceEdit.get_json_preview);
    LicenceEdit.get_json_preview();

    // load the json on the licence metadata tab
    $('#json-data').each(function(){
        var url = $(this).attr('data-url');
        var content_wrapper = $(this);
        $.getJSON(url, function(data){
            $.JSONView(data, content_wrapper);
        });
    });
});

