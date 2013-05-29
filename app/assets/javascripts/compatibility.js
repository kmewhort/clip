//= require foundation/modernizr.foundation.js
//= require foundation/jquery.foundation.tooltips.js
//= require foundation/jquery.foundation.orbit.js
//= require d3

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

    // load zurb Orbit slider (for tool)
    $('.slider').orbit({
        timer: false,
        directionalNav: true,
        bullets: true
    });

    // initialize original licence circle-pack licence graph (starting empty with remix type as "adaptation")
    $('#original-licence-display').each(function(){
        var circle_pack = new LicenceCirclePack(this, [], "adaptation");

        $('#add-original-licence-button').click(function(){
            if(circle_pack.add_licence($('#add-original-licence').val()))
                circle_pack.update();
        });
    });

    // default remix-type
});

function CompatibilityMatrix(){}
CompatibilityMatrix.initializeMatrices = function(){
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

        var active_row = $('.compatibility-row.active > td.original-work');
        if(active_row.length > 0){
            $.getScript('/compatibilities/' + active_row.text().replace(/(^[\s\:]+)|([\s\:]+$)/g, '') +
                        '/matrix.js?licence_ids[]=' + licence_ids.join("&licence_ids[]="));
        }
        else{
            $.getScript('/compatibilities/matrix.js?licence_ids[]=' + licence_ids.join("&licence_ids[]="));
        }
    });
}

function LicenceCirclePack(container, licences, remix_type){
    this.licences = licences;
    this.licence_remix_type = remix_type;

    // initialize the graph
    this.diameter = 300;
    this.padding = 40;
    this.vis = d3.select(container).append("svg:svg")
        .attr("width", this.diameter+this.padding)
        .attr("height", this.diameter+this.padding);

    this.licence_bubbles = d3.layout.pack()
        .sort(null)
        .size([this.diameter,this.diameter])
        .value(function(d) { return d.size; });

    // load list of licences into the circle packing graph
    this.licences = licences;
    this.root = this.d3data();

    // nothing to render if there are no licences
    if(this.root.children.length == 0)
      return;

    this.update();
}

LicenceCirclePack.prototype.add_licence = function(licence){
    // check whether licence is already added
    for(i = 0; i < this.root.children.length; i++){
        if(this.root.children[i].name == licence)
          return false;
    }

    this.root.children.push({
        name: licence,
        size: 1000
    });
    return true;
}

LicenceCirclePack.prototype.update = function(){
    // update the nodes' data
    this.licence_nodes = this.vis.selectAll(".node")
        .data(this.licence_bubbles.nodes(this.root),
        function(d) { return d.name; });

    // enter any new nodes
    var enter_nodes = this.licence_nodes
        .enter().append("g")
        .attr("class", function(d) { return "node" + (d.children ? "" : " leaf") });
    enter_nodes.append("circle");
    enter_leaf_nodes = enter_nodes.filter(function(d) { return !d.children; });
    enter_leaf_nodes.append("title")
        .text(function(d) { return d.name; });
    enter_leaf_nodes.append("text")
        .attr("dy", ".3em")
        .style("text-anchor", "middle")
        .text(function(d) { return d.name; });

    // Exit any old nodes
    this.licence_nodes.exit().remove();

    // update locations and sizes
    var overlap = this.overlap_distance();
    var padding = this.padding;
    this.licence_nodes.attr("transform", function(d) {
        return "translate(" + (d.x + padding/2) + "," + (d.y + padding/2) + ")"; })
      .selectAll("circle").attr("r", function(d) { return d.r + overlap; });
}

// overlap circles differently depending on the way the user remixes them (collection vs adaptation)
LicenceCirclePack.prototype.overlap_distance = function(){
    switch(this.licence_remix_type){
        case "adaptation":
            return 14;
        case "weak_adaptation":
            return 0;
        case "collection":
            return -14;
        default:
            console.log("Warning: unknown remix type.");
            return 0;
    }
}

LicenceCirclePack.prototype.set_remix_type = function(remix_type){
    if(this.licence_remix_type == remix_type)
      return false;

    this.licence_remix_type = remix_type;
    return true;
}

// list of licences to d3 data (equal sized circles)
LicenceCirclePack.prototype.d3data = function(){
    return {
      name: "root",
      children: $.map(this.licences, function(name){
            return {
                name: name,
                size: 1000
            };
        })
    };
}