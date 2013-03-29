class AddDiffScoreToFamilyTreeNode < ActiveRecord::Migration
  def change
    add_column :family_tree_nodes, :diff_score, :float
  end
end
