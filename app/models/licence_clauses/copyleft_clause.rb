class CopyleftClause < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :copyleft_applies_to, :copyleft_engages_on
  COPYLEFT_APPLIES_TO_TYPES = %w(modified_files derivatives derivatives_linking_excepted compilations)
  COPYLEFT_ENGAGES_ON_TYPES = %w(use affero distribution)

  validates :copyleft_applies_to, :copyleft_engages_on, presence: true, if: Proc.new {|c| c.licence.obligation.obligation_copyleft }
  validates :copyleft_applies_to, inclusion: {in: COPYLEFT_APPLIES_TO_TYPES, allow_nil: true}
  validates :copyleft_engages_on, inclusion: {in: COPYLEFT_ENGAGES_ON_TYPES, allow_nil: true}

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
