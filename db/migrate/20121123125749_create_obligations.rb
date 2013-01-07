class CreateObligations < ActiveRecord::Migration
  def change
    create_table :obligations do |t|
      t.string  :licence_id
      t.boolean :obligation_notice
      t.boolean :obligation_modifiable_form
      t.boolean :obligation_attribution
      t.boolean :obligation_copyleft

      t.timestamps
    end
  end
end
