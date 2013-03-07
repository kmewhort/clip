class FamilyTreeNode < ActiveRecord::Base
  belongs_to :licence

  belongs_to :family_tree
  has_many :children, :class_name => "FamilyTreeNode",
           :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "FamilyTreeNode"

  attr_accessible :diff_score

  def ancestors
    return [] if self.parent.nil?
    [self.parent] + self.parent.ancestors
  end
end