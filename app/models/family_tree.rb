class FamilyTree < ActiveRecord::Base
  has_many :family_tree_nodes, dependent: :destroy
  has_many :licences, through: :family_tree_node

  attr_accessible :title, :diff_threshold

  def root_node
    family_tree_nodes.select{|n|n.parent.nil?}.first
  end

  # build the tree by performing a diff with all licences (starting from the root node) and
  # adding ones similar above the diff_threshold
  def build_tree(root_licence, similarity_matrix)
    # clear the current tree and add the root licence to the tree
    self.family_tree_nodes.destroy
    root_node = self.family_tree_nodes.build
    root_node.licence = root_licence
    root_node.diff_score = 1.0

    # build the tree
    find_and_build_children(root_node, similarity_matrix)
  end

  private
  def find_and_build_children(root_node, similarity_matrix)
    tree = root_node
    flat = [root_node]

    # for each non-root licence
    Licence.all.delete_if{|l| l == root_node.licence}.map do |l|
      # create the node
      new_node = FamilyTreeNode.new(licence: l)
      new_node.family_tree = self

      # find the best match to the nodes already in the tree
      closest_diff_score = 0
      closest = nil
      flat.each do |node|
        diff_score = similarity_matrix[l.id][node.licence.id]
        if closest.nil? || diff_score > closest_diff_score
          closest_diff_score = diff_score
          closest = node
        end
      end

      # if the match is to the root, or if the match to the parent is weaker than for the current node,
      # simply add as a child
      if closest == root_node || (closest.diff_score >= similarity_matrix[l.id][closest.parent.licence.id])
        new_node.parent = closest
        closest.children << new_node
        new_node.diff_score = similarity_matrix[new_node.licence.id][closest.licence.id]
      # else, if the new node is more similar to the parent, rotate such the existing node is the child
      else
        # place children with the closest matching of the two
        closest.children.dup.each do |child|
          if similarity_matrix[child.licence.id][new_node.licence.id] > child.diff_score
            child.parent = new_node
            closest.children.delete_if{|n| n == child}
            new_node.children << child
            child.diff_score = similarity_matrix[child.licence.id][new_node.licence.id]
          end
        end

        # connect the new node to the parent
        new_node.parent = closest.parent
        new_node.parent.children << new_node
        new_node.diff_score = similarity_matrix[new_node.licence.id][new_node.parent.licence.id]

        # add the existing node as a child
        closest.parent = new_node
        new_node.parent.children.delete_if{|n| n == closest}
        new_node.children << closest
        closest.diff_score = similarity_matrix[closest.licence.id][new_node.licence.id]
      end

      flat << new_node
    end

    # prune away links not meeting the threshold
    flat.each do |node|
      node.parent.children.reject!{|n| n == node} if node.diff_score < self.diff_threshold
    end
  end
end
