class Compatibility < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :copyleft_compatible_with_future_versions, :copyleft_compatible_with_other,
                  :sublicense_future_versions, :sublicense_other

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
