require 'licence_text_processor'
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
  has_attached_file :text, styles: { unparsed: { format: nil },
                                     html: { format: 'html' },
                                     text: { format: 'txt' } },
                           processors: [:licence_text_processor]

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

  # find by either the licence identifier or db id (whichever is specified)
  def self.find_by_identifier(id)
    if id.match /\A\d+\Z/
      Licence.find(id)
    else
      Licence.first(conditions: {identifier: id})
    end
  end


  def html_diff_with(other_licence)
    # try to load the html diff from cache
    cache_filename = Rails.root.join('public','system','licences','diffs',"#{self.id}-#{other_licence.id}.html")
    return File.read cache_filename if File.exist? cache_filename

    # run diff and cache result /system/licences/diffs
    diff_result = HTMLDiff::DiffBuilder.new(File.read(self.text.path(:html)),
                                            File.read(other_licence.text.path(:html))).build
    File.write cache_filename, diff_result
    diff_result
  end

  # save the licence state to YAML but not the db (so changes can be reviewed before an actual save)
  def save_for_review
    is_valid = self.valid?
    if is_valid
      # include nested relations in output
      data = { attributes: @attributes }
      self.class.reflections.keys.each {|key| data[key] = self.send(key) }

      # save to file
      filename = Time.now.to_i.to_s + (!identifier.nil? ? ("_" + identifier) : "") + ".yml"
      File.open(Rails.root.join('public', 'review_pending', filename), 'w') do |f|
        YAML.dump(data, f)
      end
    end
    is_valid
  end

  # full title w/ licence version identifier
  def full_title
    full_title = title + ' ' + version
    full_title.sub /\+\Z/, ' or later'
  end

  # get all versions of the this licence
  def all_versions
    result = Licence.where(title: self.title)
    result = [] if result.nil?

    # special case handling for LGPL, which changed names from 2.0 to 2.1
    if title == 'GNU Library General Public License'
      result += Licence.where(title: 'GNU Lesser General Public License')
    elsif title == 'GNU Lesser General Public License'
      result += Licence.where(title: 'GNU Library General Public License')
    end

    # sort by version
    result.sort! { |a,b| a.version <=> b.version }
    # special case for BSD, which has decreasing number of clauses labels with future versions
    if title == 'BSD'
      result.reverse!
    end
    result
  end

  def build_children
    # need to directly set parent of nested attributes for validation w/o save
    self.build_compliance.licence = self if self.compliance.nil?
    self.build_right.licence = self if self.right.nil?
    self.build_obligation.licence = self if self.obligation.nil?
    self.build_patent_clause.licence = self if self.patent_clause.nil?
    self.build_attribution_clause.licence = self if self.attribution_clause.nil?
    self.build_copyleft_clause.licence = self if self.copyleft_clause.nil?
    self.build_compatibility.licence = self if self.compatibility.nil?
    self.build_termination.licence = self if self.termination.nil?
    self.build_changes_to_term.licence = self if self.changes_to_term.nil?
    self.build_disclaimer.licence = self if self.disclaimer.nil?
    self.build_conflict_of_law.licence = self if self.conflict_of_law.nil?
  end

  # manually define json structure to provide a user-friendly ordering
  def as_json(options={})
    result = {
        id: self.identifier,
        title: self.title,
        version: self.version
    }
    unless options[:brief]
      result[:url] = self.url
      result[:maintainer] = self.maintainer
      result[:maintainer_type] = self.maintainer_type
      result[:domain_data] = self.domain_data
      result[:domain_software] = self.domain_software
      result[:domain_content] = self.domain_content
      result[:compliance] = self.compliance.as_json(options)
      result[:rights] = self.right.as_json(options)
      result[:obligations] = self.obligation.as_json(options)
      result[:attribution] = self.attribution_clause.as_json(options)
      result[:copyleft] = self.copyleft_clause.as_json(options)
      result[:patents] = self.patent_clause.as_json(options)
      result[:compatibility] = self.compatibility.as_json(options)
      result[:termination] = self.termination.as_json(options)
      result[:changes_to_terms] = self.changes_to_term.as_json(options)
      result[:disclaimers] = self.disclaimer.as_json(options)
      result[:conflict_of_laws] = self.conflict_of_law.as_json(options)
    end
    result
  end
end