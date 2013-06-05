class LicencesController < ApplicationController
  before_filter :find_licences, only: [:index]
  before_filter :find_licence, except: [:new, :create, :index]
  before_filter :build_licence, only: [:new, :create]
  authorize_resource

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: JSON.pretty_generate(@licences.as_json(brief: true)) }
    end
  end

  def show
    @tab = params[:tab].nil? ? "licence_info" : params[:tab]

    respond_to do |format|
      format.html
      format.json { render json: JSON.pretty_generate(@licence.as_json(except: [:created_at, :updated_at, :id, :licence_id])) }
    end
  end

  def new
    respond_to do |format|
      format.html { render notice: notice }
      format.json { render json: @licence }
    end
  end

  def edit
  end

  def create
    result = true
    success_notice = ''
    unless params[:preview]
      if params[:submit_for_review] == "true"
        result = @licence.save_for_review
        success_notice = 'Thank you for your submission of a new licence! We will review it and post it on the website shortly.'
      else
        result = @licence.save unless params[:preview]
        success_notice = 'Licence was successfully created.'
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to @licence, notice: success_notice }
        format.json { render json: @licence  }
      else
        format.html { render action: "new" }
        format.json { render json: @licence.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @licence.assign_attributes(params[:licence])

    result = true
    success_notice = ''
    unless params[:preview]
      if params[:submit_for_review] == "true"
        result = @licence.save_for_review
        success_notice = 'Thank you for your submission! We will review your suggested changes shortly.'
      else
        result = @licence.save unless params[:preview]
        success_notice = 'Licence was successfully updated.'
      end
    end

    respond_to do |format|
      if result
        format.html { redirect_to @licence, notice: success_notice }
        format.json { render json: @licence  }
      else
        format.html { render action: "edit" }
        format.json { render json: @licence.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @licence.destroy

    respond_to do |format|
      format.html { redirect_to licences_url }
      format.json { head :no_content }
    end
  end

  def compare_to
    @licence_a = Licence.find_by_identifier(params[:id])
    @licence_b = Licence.find_by_identifier(params[:licence_id])
    @selectable = params[:selectable]

    # render/cache an HTML diff of the two licences
    @comparison_html = @licence_a.html_diff_with(@licence_b)

    respond_to do |format|
      format.js
    end
  end

  private
  def find_licences
    table_cols = Licence.columns.map(&:name)
    filters = params.dup.keep_if{|key,val| table_cols.include? key }
    filters.each do |key,val|
      filters[key] = true if val == "true"
      filters[key] = false if val == "false"
      filters[key] = val.split(',') if val.include? ','
    end
    @licences = Licence.all(conditions: filters, order: :identifier )
  end

  def find_licence
    @licence = Licence.find_by_identifier(params[:id])
    @family_trees = @licence.family_tree_nodes.map {|ftn| ftn.family_tree }
  end

  def build_licence
    @licence = Licence.new(params[:licence])
    @licence.build_children
  end
end
