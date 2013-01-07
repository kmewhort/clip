class PatentClause < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :patent_licence_extends_to,
                  :patent_retaliation_applies_to, :patent_retaliation_upon_counterclaim, :patent_retaliation_upon_originating_claim
  PATENT_LICENCE_EXTENDS_TO_TYPES = %w(licensors_contributions entire_work)
  PATENT_RETALIATION_APPLIES_TO = %w(specific_work all_works_under_same_licence)

  validates :patent_licence_extends_to, :patent_retaliation_applies_to, presence: true
  validates :patent_licence_extends_to, inclusion: PATENT_LICENCE_EXTENDS_TO_TYPES
  validates :patent_retaliation_applies_to, inclusion: PATENT_RETALIATION_APPLIES_TO

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
