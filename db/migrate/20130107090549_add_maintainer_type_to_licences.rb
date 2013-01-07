class AddMaintainerTypeToLicences < ActiveRecord::Migration
  def change
    add_column :licences, :maintainer_type, :string
  end
end
