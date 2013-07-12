class FamilyTree < ActiveRecord::Base
  has_and_belongs_to_many :licences

  attr_accessible :title, :diff_method, :diff_threshold, :tree_data

  # build the tree of similar licences using the similarity_tree library
  def build_tree(root_licence, show_progress = false)
    matrix = SimilarityTree::SimilarityMatrix.new(Licence.all,
               id_func: :identifier, content_func: :fulltext_filename,
               show_progress: show_progress,
               calculation_method: self.diff_method.to_sym)
    tree = matrix.build_tree(root_licence.identifier, self.diff_threshold)
    tree.each_node {|n| self.licences << Licence.find_by_identifier(n.id) }
    self.tree_data = tree.to_json
    tree
  end

  def to_json
    tree_data
  end
end
