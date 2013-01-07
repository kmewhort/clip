class Termination < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :termination_automatic, :termination_discretionary, :termination_reinstatement

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
