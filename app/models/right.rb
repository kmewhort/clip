class Right < ActiveRecord::Base
  belongs_to :licence
  attr_accessible :licence_id, :covers_circumventions, :covers_copyright, :covers_moral_rights, :covers_neighbouring_rights,
                  :covers_patents_explicitly, :covers_sgdrs, :covers_trademarks,
                  :prohibits_commercial_use, :prohibits_tpms, :prohibits_tpms_unless_parallel, :prohibits_patent_actions,
                  :right_to_distribute, :right_to_modify, :right_to_use_and_reproduce

  def as_json(options = {})
    super( except: [ :id, :licence_id, :created_at, :updated_at ] )
  end
end
