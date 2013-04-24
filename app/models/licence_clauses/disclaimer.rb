class Disclaimer < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :disclaimer_indemnity, :disclaimer_liability, :disclaimer_warranty, :warranty_noninfringement

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
