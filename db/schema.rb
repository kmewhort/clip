# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130213111511) do

  create_table "attribution_clauses", :force => true do |t|
    t.string   "licence_id"
    t.string   "attribution_type"
    t.text     "attribution_details"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "changes_to_terms", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "licence_changes_effective_immediately"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "compatibilities", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "sublicense_future_versions"
    t.string   "sublicense_other"
    t.boolean  "copyleft_compatible_with_future_versions"
    t.string   "copyleft_compatible_with_other"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "compliances", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "is_okd_compliant"
    t.boolean  "is_osi_compliant"
    t.boolean  "is_dfcw_compliant"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "conflict_of_laws", :force => true do |t|
    t.string   "licence_id"
    t.string   "law_of"
    t.string   "forum_of"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "copyleft_clauses", :force => true do |t|
    t.string   "licence_id"
    t.string   "copyleft_applies_to"
    t.string   "copyleft_engages_on"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "disclaimers", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "disclaimer_warranty"
    t.boolean  "disclaimer_liability"
    t.boolean  "disclaimer_indemnity"
    t.boolean  "warranty_noninfringement"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "licence_families", :force => true do |t|
    t.text     "family_tree"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "licences", :force => true do |t|
    t.string   "identifier"
    t.string   "title"
    t.string   "url"
    t.string   "maintainer"
    t.boolean  "domain_content"
    t.boolean  "domain_data"
    t.boolean  "domain_software"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "maintainer_type"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "text_file_name"
    t.string   "text_content_type"
    t.integer  "text_file_size"
    t.datetime "text_updated_at"
    t.string   "version"
    t.string   "licence_family_id"
  end

  create_table "obligations", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "obligation_notice"
    t.boolean  "obligation_modifiable_form"
    t.boolean  "obligation_attribution"
    t.boolean  "obligation_copyleft"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "patent_clauses", :force => true do |t|
    t.string   "licence_id"
    t.string   "patent_licence_extends_to"
    t.boolean  "patent_retaliation_upon_originating_claim"
    t.boolean  "patent_retaliation_upon_counterclaim"
    t.string   "patent_retaliation_applies_to"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "rights", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "right_to_use_and_reproduce"
    t.boolean  "right_to_modify"
    t.boolean  "right_to_distribute"
    t.boolean  "covers_copyright"
    t.boolean  "covers_neighbouring_rights"
    t.boolean  "covers_sgdrs"
    t.boolean  "covers_moral_rights"
    t.boolean  "covers_trademarks"
    t.boolean  "covers_circumventions"
    t.boolean  "covers_patents_explicitly"
    t.boolean  "prohibits_commercial_use"
    t.boolean  "prohibits_tpms"
    t.boolean  "prohibits_tpms_unless_parallel"
    t.boolean  "prohibits_patent_actions"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "scores", :force => true do |t|
    t.string   "licence_id"
    t.float    "openness"
    t.float    "licensee_legal_risk"
    t.float    "licensee_business_risk"
    t.float    "licensee_freedom"
    t.float    "licensor_legal_risk"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "terminations", :force => true do |t|
    t.string   "licence_id"
    t.boolean  "termination_automatic"
    t.boolean  "termination_discretionary"
    t.boolean  "termination_reinstatement"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

end
