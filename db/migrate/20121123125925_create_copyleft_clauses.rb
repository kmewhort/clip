class CreateCopyleftClauses < ActiveRecord::Migration
  def change
    create_table :copyleft_clauses do |t|
      t.string :licence_id
      t.string :copyleft_applies_to
      t.string :copyleft_engages_on

      t.timestamps
    end
  end
end
