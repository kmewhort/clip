class CreateDisclaimers < ActiveRecord::Migration
  def change
    create_table :disclaimers do |t|
      t.string :licence_id
      t.boolean :disclaimer_warranty
      t.boolean :disclaimer_liability
      t.boolean :disclaimer_indemnity
      t.boolean :warranty_noninfringement

      t.timestamps
    end
  end
end
