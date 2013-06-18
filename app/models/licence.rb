require 'licence_text_processor'
require 'nokogiri'
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

    # read in the html, simplify it, and diff it
    text_a = simplify_html File.read(self.text.path(:html))
    text_b = simplify_html File.read(other_licence.text.path(:html))
    diff_result = HTMLDiff::DiffBuilder.new(text_a,text_b).build

    # cache result to /system/licences/diffs
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
      yaml = YAML.dump(data)
      File.open(Rails.root.join('public', 'review_pending', filename), 'w') { |f| f << yaml }
      #AdminMailer.update_notification(self, yaml).deliver
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
    result = Licence.where(title: self.title).delete_if{|l| l.version.empty? }
    return [] if result.empty?

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
    self.build_score if self.score.nil?

    # need to directly set parent of nested attributes for validation w/o save
    self.compliance.licence = self
    self.right.licence = self
    self.obligation.licence = self
    self.patent_clause.licence = self
    self.attribution_clause.licence = self
    self.copyleft_clause.licence = self
    self.compatibility.licence = self
    self.termination.licence = self
    self.changes_to_term.licence = self
    self.disclaimer.licence = self
    self.conflict_of_law.licence = self
    self.score.licence = self
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

  private

  # strips html down to basic tags (to make comparisons better)
  def simplify_html(html)
    doc = Nokogiri::HTML.parse(html)

    # strip to allowed tags
    allowed_tags = %w(h1 h2 h3 h4 h5 h6 body p br ul ol li)
    (doc.css("*") - doc.css(allowed_tags.join(","))).each do |node|
      unless node == doc.root
        node.children.each {|c| c.parent = node.parent}
        node.remove
      end
    end

    # strip class and style attributes
    doc.xpath('//@class | //@style').remove
    doc.serialize
  end
end