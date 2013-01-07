class CreateChangesToTerms < ActiveRecord::Migration
  def change
    create_table :changes_to_terms do |t|
      t.string :licence_id
      t.boolean :licence_changes_effective_immediately

      t.timestamps
    end
  end
end
