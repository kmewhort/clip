class CreateRights < ActiveRecord::Migration
  def change
    create_table :rights do |t|
      t.string  :licence_id
      t.boolean :right_to_use_and_reproduce
      t.boolean :right_to_modify
      t.boolean :right_to_distribute
      t.boolean :covers_copyright
      t.boolean :covers_neighbouring_rights
      t.boolean :covers_sgdrs
      t.boolean :covers_moral_rights
      t.boolean :covers_trademarks
      t.boolean :covers_circumventions
      t.boolean :covers_patents_explicitly
      t.boolean :prohibits_commercial_use
      t.boolean :prohibits_tpms
      t.boolean :prohibits_tpms_unless_parallel
      t.boolean :prohibits_patent_actions

      t.timestamps
    end
  end
end
