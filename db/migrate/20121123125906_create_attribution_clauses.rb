class CreateAttributionClauses < ActiveRecord::Migration
  def change
    create_table :attribution_clauses do |t|
      t.string :licence_id
      t.string :attribution_type
      t.text :attribution_details

      t.timestamps
    end
  end
end
