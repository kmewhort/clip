class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.string :licence_id
      t.float :openness
      t.float :licensee_legal_risk
      t.float :licensee_business_risk
      t.float :licensee_freedom
      t.float :licensor_legal_risk
      t.timestamps
    end
  end
end
