class AddAttachmentTextToLicences < ActiveRecord::Migration
  def self.up
    change_table :licences do |t|
      t.attachment :text
    end
  end

  def self.down
    drop_attached_file :licences, :text
  end
end
