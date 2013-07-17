class SimilarityTreeToLib < ActiveRecord::Migration
  def up
    drop_table :family_trees
    drop_table :family_tree_nodes

    create_table "family_trees" do |t|
      t.string "title"
      t.string "diff_method"
      t.float  "diff_threshold"
      t.text "tree_data"
    end

    create_table :family_trees_licences, :id => false do |t|
      t.references :family_tree, :null => false
      t.references :licence, :null => false
    end
    add_index(:family_trees_licences, [:family_tree_id, :licence_id], :unique => true)
  end

  def down
  end
end
