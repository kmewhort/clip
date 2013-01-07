class CreatePatentClauses < ActiveRecord::Migration
  def change
    create_table :patent_clauses do |t|
      t.string :licence_id
      t.string :patent_licence_extends_to
      t.boolean :patent_retaliation_upon_originating_claim
      t.boolean :patent_retaliation_upon_counterclaim
      t.string :patent_retaliation_applies_to

      t.timestamps
    end
  end
end
