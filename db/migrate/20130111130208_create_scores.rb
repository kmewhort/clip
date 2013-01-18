class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.string :licence_id
      t.timestamps
    end
  end
end
