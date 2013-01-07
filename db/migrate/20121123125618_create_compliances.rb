class CreateCompliances < ActiveRecord::Migration
  def change
    create_table :compliances do |t|
      t.string  :licence_id
      t.boolean :is_okd_compliant
      t.boolean :is_osi_compliant
      t.boolean :is_dfcw_compliant

      t.timestamps
    end
  end
end
