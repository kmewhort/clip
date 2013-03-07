require 'clip_similarity'
class FamilyTree < ActiveRecord::Base
  has_many :family_tree_nodes
  has_many :licences, through: :family_tree_node

  attr_accessible :title, :diff_threshold

  def root_node
    family_tree_nodes.select{|n|n.parent.nil?}.first
  end

  def is_root?
    parent_id == null
  end

  # build the tree by performing a diff with all licences (starting from the root node) and
  # adding ones similar above the diff_threshold
  def build_tree(root_licence, similarity_matrix = nil)
    # calculate the licence similarity matrix
    if !similarity_matrix
      similarity_matrix = ClipSimilarity.calculate_with_diff(
          Licence.all.map{|l| {id: l.id, filename: l.text.path } })
    end

    # clear the current tree and add the root licence to the tree
    self.family_tree_nodes.destroy
    root_node = self.family_tree_nodes.build
    root_node.licence = root_licence
    root_node.diff_score = 1.0

    # build the tree
    find_and_build_children(root_node, similarity_matrix)
  end

  private
  def find_and_build_children(node, similarity_matrix)
    # compare to every other non-ancestral licence
    Licence.all.each do |licence|
      next if licence == node.licence #||
              #(node.ancestors.select{|n| n.licence == licence }.length > 0)


      diff_score = similarity_matrix[node.licence.id][licence.id]
      next if diff_score < self.diff_threshold

      # if the licence is already in the family tree, move it to be a child of this node instead if
      # the match is stronger
      existing_node = self.family_tree_nodes.select{|n|n.licence == licence}.first
      if existing_node
        if diff_score > existing_node.diff_score
          existing_node.parent.children.reject! {|n|n == existing_node}
          existing_node.parent = node
          existing_node.diff_score = diff_score
          node.children.push(existing_node)
        end
        next
      end

      new_child_node = self.family_tree_nodes.build
      new_child_node.licence = licence
      new_child_node.diff_score =  diff_score
      new_child_node.parent = node
      node.children.push(new_child_node)
    end

    # recurse on the children, other than already-calculated children that were moved
    node.children.each do |child_node|
      puts 'Recursing from ' + node.licence.identifier + ' into ' + child_node.licence.identifier
      find_and_build_children(child_node, similarity_matrix) if node.children.include? child_node
    end
  end
end
