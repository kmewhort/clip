class CreateTerminations < ActiveRecord::Migration
  def change
    create_table :terminations do |t|
      t.string :licence_id
      t.boolean :termination_automatic
      t.boolean :termination_discretionary
      t.boolean :termination_reinstatement

      t.timestamps
    end
  end
end
