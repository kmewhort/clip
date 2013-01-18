class AddFamilyToLicence < ActiveRecord::Migration
  def change
    add_column :licences, :family, :string
  end
end
