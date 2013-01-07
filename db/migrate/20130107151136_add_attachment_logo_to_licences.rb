class AddAttachmentLogoToLicences < ActiveRecord::Migration
  def self.up
    change_table :licences do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :licences, :logo
  end
end
