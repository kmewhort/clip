class Obligation < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :obligation_attribution, :obligation_copyleft, :obligation_modifiable_form, :obligation_notice

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
