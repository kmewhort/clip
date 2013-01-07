class Compliance < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :is_dfcw_compliant, :is_okd_compliant, :is_osi_compliant

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
