class LicenceFamily < ActiveRecord::Base
  has_many :licences
  attr_accessible :family_tree  #json structure mapping out the tree of licences in the family
end
