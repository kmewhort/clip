class AddVersionToLicence < ActiveRecord::Migration
  def change
    add_column :licences, :version, :string
  end
end
