class LicencesController < ApplicationController
  def index
    table_cols = Licence.columns.map(&:name)
    filters = params.dup.keep_if{|key,val| table_cols.include? key }
    filters.each do |key,val|
      filters[key] = true if val == "true"
      filters[key] = false if val == "false"
      filters[key] = val.split(',') if val.include? ','
    end

    @licences = Licence.all(conditions: filters )

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @licences }
    end
  end

  def show
    @licence = Licence.find(params[:id])
    @tab = params[:tab].nil? ? "licence_info" : params[:tab]

    respond_to do |format|
      format.html
      format.json { render json: @licence }
    end
  end

  def new
    @licence = Licence.new

    # TODO: remove this, it's a temporary feature to load in the old json data
    notice = "Remember to set: "
    if !params[:import].nil?
      old_json_filename = Rails.root.join('tmp','old_json', params[:import] + '.json')
      json = JSON.parse(IO.read(old_json_filename))
      @licence.domain_content = json["domain_content"]
      @licence.domain_software = json["domain_software"]
      @licence.domain_data = json["domain_data"]
      notice += "version, "
      @licence.maintainer = json["maintainer"]
      notice += "maintainer type, "
      @licence.identifier = json["id"]
      @licence.title = json["title"]
      @licence.url = json["url"]

      @licence.compliance.is_dfcw_compliant = json["is_dfcw_compliant"]
      @licence.compliance.is_osi_compliant = json["is_osi_compliant"]
      @licence.compliance.is_okd_compliant = json["is_okd_compliant"]

      @licence.right.right_to_use_and_reproduce = json["rights"]["right_to_use_and_reproduce"]
      @licence.right.right_to_modify = json["rights"]["right_to_modify"]
      @licence.right.right_to_distribute = json["rights"]["right_to_distribute"]
      @licence.right.covers_circumventions = json["rights"]["covers_circumventions"]
      @licence.right.covers_copyright = json["rights"]["covers_copyright"]
      @licence.right.covers_moral_rights = json["rights"]["covers_moral_rights"]
      @licence.right.covers_neighbouring_rights = json["rights"]["covers_neighbouring_rights"]
      @licence.right.covers_patents_explicitly = json["rights"]["covers_patents"]
      @licence.right.covers_sgdrs = json["rights"]["covers_sgdrs"]
      @licence.right.covers_trademarks = json["rights"]["covers_trademarks"]
      @licence.right.prohibits_commercial_use = json["rights"]["prohibits_commercial_use"]
      @licence.right.prohibits_tpms = json["rights"]["prohibits_tpms"]
      @licence.right.prohibits_tpms_unless_parallel = json["rights"]["prohibits_tpms_unless_parallel"]
      notice += "rights - prohibits patent actions, "

      @licence.obligation.obligation_attribution =
          (json["obligations"]["obligation_attribution_flexible"] || json["obligations"]["obligation_attribution_specific"])
      @licence.obligation.obligation_copyleft = json["obligations"]["obligation_copyleft"]
      @licence.obligation.obligation_modifiable_form = json["obligations"]["obligation_modifiable_form"]
      @licence.obligation.obligation_notice = json["obligations"]["obligation_notice"]
      if @licence.obligation.obligation_attribution
        @licence.attribution_clause.attribution_type = "flexible" if json["obligations"]["obligation_attribution_flexible"]
        @licence.attribution_clause.attribution_type = "specific" if json["obligations"]["obligation_attribution_specific"]
        @licence.attribution_clause.attribution_details = json["obligations"]["obligation_attribution_specific_details"]
      end

      notice += "patents - [all], "

      @licence.copyleft_clause.copyleft_applies_to = json["copyleft"]["copyleft_on"]
      @licence.copyleft_clause.copyleft_engages_on = json["copyleft"]["copyleft_engages_on"]

      @licence.compatibility.copyleft_compatible_with_future_versions = json["sublicensing"]["copyleft_compatible_with_future_versions"]
      @licence.compatibility.copyleft_compatible_with_other = json["sublicensing"]["copyleft_compatible_with_other"]
      @licence.compatibility.sublicense_future_versions = json["sublicensing"]["sublicense_future_versions"]
      @licence.compatibility.sublicense_other = json["sublicensing"]["sublicense_other"]

      @licence.termination.termination_automatic = json["termination"]["termination_automatic"]
      @licence.termination.termination_discretionary = json["termination"]["termination_discretionary"]
      @licence.termination.termination_reinstatement = json["termination"]["termination_reinstatement"]

      @licence.changes_to_term.licence_changes_effective_immediately =
          json["license_changes"]["license_changes_effective_immediately"]

      @licence.disclaimer.disclaimer_indemnity = json["disclaimers"]["disclaimer_indemnity"]
      @licence.disclaimer.disclaimer_liability = json["disclaimers"]["disclaimer_liability"]
      @licence.disclaimer.disclaimer_warranty = json["disclaimers"]["disclaimer_warranty"]
      @licence.disclaimer.warranty_noninfringement = json["disclaimers"]["warranty_noninfringement"]

      @licence.conflict_of_law.forum_of = json["conflict_of_laws"]["forum_of"]
      @licence.conflict_of_law.law_of = json["conflict_of_laws"]["law_of"]
    end

    respond_to do |format|
      format.html { render notice: notice }
      format.json { render json: @licence }
    end
  end

  def edit
    @licence = Licence.find(params[:id])
  end

  def create
    @licence = Licence.new(params[:licence])

    result = true
    result = @licence.save unless params[:preview]

    respond_to do |format|
      if result
        format.html { redirect_to @licence, notice: 'Licence was successfully created.' }
        format.json { render json: @licence  }
      else
        format.html { render action: "new" }
        format.json { render json: @licence.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @licence = Licence.find(params[:id])

    result = true
    if params[:preview]
      @licence.assign_attributes(params[:licence])
    else
      result = @licence.update_attributes(params[:licence]) unless params[:preview]
    end

    respond_to do |format|
      if result
        format.html { redirect_to @licence, notice: 'Licence was successfully updated.' }
        format.json { render json: @licence  }
      else
        format.html { render action: "edit" }
        format.json { render json: @licence.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @licence = Licence.find(params[:id])
    @licence.destroy

    respond_to do |format|
      format.html { redirect_to licences_url }
      format.json { head :no_content }
    end
  end
end
