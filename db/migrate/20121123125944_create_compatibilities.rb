class CreateCompatibilities < ActiveRecord::Migration
  def change
    create_table :compatibilities do |t|
      t.string :licence_id
      t.boolean :sublicense_future_versions
      t.string :sublicense_other
      t.boolean :copyleft_compatible_with_future_versions
      t.string :copyleft_compatible_with_other

      t.timestamps
    end
  end
end
