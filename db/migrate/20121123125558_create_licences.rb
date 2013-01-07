class CreateLicences < ActiveRecord::Migration
  def change
    create_table :licences do |t|
      t.string :identifier
      t.string :title
      t.string :url
      t.string :maintainer
      t.boolean :domain_content
      t.boolean :domain_data
      t.boolean :domain_software

      t.timestamps
    end
  end
end
