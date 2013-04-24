class ConflictOfLaw < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :forum_of, :law_of
  FORUM_TYPES = %w(unspecified licensor plaintiff defendant forum specific)
  LAW_TYPES = %w(unspecified licensor plaintiff defendant specific)

  validates :forum_of, :law_of, presence: true
  validates :forum_of, inclusion: FORUM_TYPES
  validates :forum_of, inclusion: LAW_TYPES

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
