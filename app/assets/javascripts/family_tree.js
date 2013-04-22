/*
 *= require d3
 *= require jquery.ui.combobox
 *= require licence_compare
 */
$(document).ready(function(){
    new FamilyTree();
});

function FamilyTree(){
    // render the similarity trees
    $('.licence-similarity-tree').each(function(){
        var tree = new SimilarityTree(this,
            $(this).data('family-tree-root'), 958, 400);
    });

    // render the licence family selection combobox (loading the similarity tree when a selection is made)
    $('.licence-family-select-combo').combobox().on("comboboxselected", function(event, ui){
        var family_tree_url = '/family_trees/' + $(this).val() + '.js';
        $.getScript(family_tree_url);
    });
}

// tree of similary licences, where distance apart approximates the difference between any two licences
function SimilarityTree(element, root, width, height){
    this.root = root;
    this.tree = d3.layout.tree()
        .size([height, width]);

    this.vis = d3.select(element).append("svg:svg")
        .attr("width", width)
        .attr("height", height)
        .append("svg:g");

    this.height = height;
    this.width = width;
    this.root.x = 0;
    this.root.y = 0;

    this.selection_a = null;
    this.selection_b = null;

    this.update(this.root);
}

SimilarityTree.prototype.update = function(source) {
    var similarity_tree = this;

    // compute the new tree layout.
    var nodes = this.tree.nodes(this.root);

    // calculate the length between nodes (normalized diff scores)
    this.calculate_length_between(nodes);

    // horizontal width dependent on difference
    nodes.forEach(function(d) { d.y = (d.parent ? d.parent.y : 0) + 50.0 + d.length * 120; });

    // calculate offsets for centering
    this.calculate_offsets(nodes);

    // update the node data, enter, exit
    var node = this.vis.selectAll("g.node")
        .data(nodes, function(d) { return d.id; });

    var nodeEnter = node.enter().append("svg:g")
        .attr("class", "node")
        .attr("transform", function(d) {
            return "translate(" + (d.y  + similarity_tree.y_offset) + "," +
                (d.x + similarity_tree.x_offset) + ")"; })
        .on("click", function(d) {
            if(similarity_tree.selection_a == null || similarity_tree.selection_b != null){
                similarity_tree.selection_a = d;
                similarity_tree.selection_b = null;
            }
            else{
                similarity_tree.selection_b = d;
                similarity_tree.compare_selections();
            }
            similarity_tree.update(similarity_tree.root);
        });
    nodeEnter.append("svg:circle")
        .attr("r", 7);
    nodeEnter.append("svg:text")
        .attr("x", function(d) { return d.children ? -10 : 10; })
        .attr("dy", ".35em")
        .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
        .text(function(d) { return d.licence.identifier; })
        .style("fill-opacity", 1);
    var nodeExit = node.exit().remove();

    // update selections
    node.selectAll("circle")
        .attr("class", function(d) {
            return ((d == similarity_tree.selection_a) || (d == similarity_tree.selection_b)) ? 'selected' : '' });


    // Update the links, enter, exit
    var link = this.vis.selectAll("path.link")
        .data(this.tree.links(nodes), function(d) { return d.target.id; });

    var diagonal = d3.svg.diagonal()
        .projection(function(d) {return [d.y + similarity_tree.y_offset, d.x + similarity_tree.x_offset];});
    link.enter().insert("svg:path", "g")
        .attr("class", "link")
        .attr("d", diagonal);

    link.exit().remove();
}

// offsets to center tree
SimilarityTree.prototype.calculate_offsets = function(nodes){
    var x_range = [Number.MAX_VALUE,0];
    var y_range = [Number.MAX_VALUE,0];
    for(i in nodes){
        if(nodes[i].x > x_range[1])
            x_range[1] = nodes[i].x;
        if(nodes[i].y > y_range[1])
            y_range[1] = nodes[i].y;
        if(nodes[i].x < x_range[0])
            x_range[0] = nodes[i].x;
        if(nodes[i].y < y_range[0])
            y_range[0] = nodes[i].y;
    }

    this.x_offset = -x_range[0] + 10;
    //this.y_offset = (this.width - (y_range[1] - y_range[0])) / 2 - 10 - 100;
    this.y_offset = 0;
}

// horizontal distance between nodes (normalized diff scores), in-place
SimilarityTree.prototype.calculate_length_between = function(nodes){
    var diff_score_range = [Number.MAX_VALUE,0];
    nodes.forEach(function(d) {
        if(d.diff_score > diff_score_range[1])
            diff_score_range[1] = d.diff_score;
        if(d.diff_score < diff_score_range[0])
            diff_score_range[0] = d.diff_score;
    });
    nodes.forEach(function(d) {
        d.length = (d.diff_score - diff_score_range[0]) / (diff_score_range[1] - diff_score_range[0]);
    });
}

// compare the text of two selected licences
SimilarityTree.prototype.compare_selections = function(){
    licence_a = this.selection_a.licence.id;
    licence_b = this.selection_b.licence.id;
    (new LicenceCompare()).compareLicences(licence_a, licence_b);
}
