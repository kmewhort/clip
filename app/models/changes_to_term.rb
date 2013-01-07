class ChangesToTerm < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :licence_changes_effective_immediately

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
