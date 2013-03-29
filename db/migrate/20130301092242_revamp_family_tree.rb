class RevampFamilyTree < ActiveRecord::Migration
  def up
    drop_table :licence_families
    remove_column :licences, :licence_family_id

    create_table :family_trees do |t|
      t.string 'title'
      t.float 'diff_threshold'
    end

    create_table :family_tree_nodes do |t|
      t.integer 'licence_id'
      t.integer 'family_tree_id'
      t.integer 'parent_id'
    end
  end

  def down
  end
end
