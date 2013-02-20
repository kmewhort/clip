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
