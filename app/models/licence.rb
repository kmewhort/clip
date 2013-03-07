class Licence < ActiveRecord::Base
  attr_accessible :domain_content, :domain_data, :domain_software, :identifier, :version,
    :maintainer, :maintainer_type, :title, :url,
    :compliance_attributes, :right_attributes, :obligation_attributes, :patent_clause_attributes,
    :attribution_clause_attributes, :copyleft_clause_attributes, :compatibility_attributes,
    :termination_attributes, :changes_to_term_attributes, :disclaimer_attributes, :conflict_of_law_attributes,
    :logo, :text
  MAINTAINER_TYPES = %w(gov ngo private)

  has_one :compliance, dependent: :destroy
  has_one :right, dependent: :destroy
  has_one :obligation, dependent: :destroy
  has_one :patent_clause, dependent: :destroy
  has_one :attribution_clause, dependent: :destroy
  has_one :copyleft_clause, dependent: :destroy
  has_one :compatibility, dependent: :destroy
  has_one :termination, dependent: :destroy
  has_one :changes_to_term, dependent: :destroy
  has_one :disclaimer, dependent: :destroy
  has_one :conflict_of_law, dependent: :destroy

  has_one :score, dependent: :destroy
  after_save do
    self.build_score if self.score.nil?
    self.score.score_licence
    self.score.save
  end

  has_many :family_tree_nodes

  has_attached_file :logo, styles: { medium: "220x220" }
  has_attached_file :text

  accepts_nested_attributes_for :compliance, :allow_destroy => true
  accepts_nested_attributes_for :right, :allow_destroy => true
  accepts_nested_attributes_for :obligation, :allow_destroy => true
  accepts_nested_attributes_for :patent_clause, :allow_destroy => true
  accepts_nested_attributes_for :attribution_clause, :allow_destroy => true
  accepts_nested_attributes_for :copyleft_clause, :allow_destroy => true
  accepts_nested_attributes_for :compatibility, :allow_destroy => true
  accepts_nested_attributes_for :termination, :allow_destroy => true
  accepts_nested_attributes_for :changes_to_term, :allow_destroy => true
  accepts_nested_attributes_for :disclaimer, :allow_destroy => true
  accepts_nested_attributes_for :conflict_of_law, :allow_destroy => true

  validates :identifier, uniqueness: true
  validates :identifier, :title, presence: true
  validates :maintainer_type, inclusion: MAINTAINER_TYPES

  def build_children
    self.build_compliance if self.compliance.nil?
    self.build_right if self.right.nil?
    self.build_obligation if self.obligation.nil?
    self.build_patent_clause if self.patent_clause.nil?
    self.build_attribution_clause if self.attribution_clause.nil?
    self.build_copyleft_clause if self.copyleft_clause.nil?
    self.build_compatibility if self.compatibility.nil?
    self.build_termination if self.termination.nil?
    self.build_changes_to_term if self.changes_to_term.nil?
    self.build_disclaimer if self.disclaimer.nil?
    self.build_conflict_of_law if self.conflict_of_law.nil?
  end

  def as_json(options={})
    # manually define json structure to provide a user-friendly ordering
    {
        id: self.identifier,
        title: self.title,
        version: self.version,
        url: self.url,
        maintainer: self.maintainer,
        maintainer_type: self.maintainer_type,
        domain_data: self.domain_data,
        domain_software: self.domain_software,
        domain_content: self.domain_content,
        compliance: self.compliance.as_json(options),
        rights: self.right.as_json(options),
        obligations: self.obligation.as_json(options),
        attribution: self.attribution_clause.as_json(options),
        copyleft: self.copyleft_clause.as_json(options),
        patents: self.patent_clause.as_json(options),
        compatibility: self.compatibility.as_json(options),
        termination: self.termination.as_json(options),
        changes_to_terms: self.changes_to_term.as_json(options),
        disclaimers: self.disclaimer.as_json(options),
        conflict_of_laws: self.conflict_of_law.as_json(options),
    }
  end

end