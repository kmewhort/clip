class FamilyTreeNode < ActiveRecord::Base
  belongs_to :licence

  belongs_to :family_tree
  has_many :children, :class_name => "FamilyTreeNode",
           :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "FamilyTreeNode"

  attr_accessible :parent, :children, :licence, :diff_score

  def ancestors
    return [] if self.parent.nil?
    [self.parent] + self.parent.ancestors
  end

  def as_json(options={})
    result = super(options)
    result['children'] = children unless children.empty?
    result['licence'] = {
        id: licence.id,
        identifier: licence.identifier,
        title: licence.title
    }
    result
  end
end