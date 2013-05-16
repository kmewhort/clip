class CompatibilitiesController < ApplicationController
  before_filter :find_compatibility

  def matrix
    # if no other licences are specified for compatibility determination, select a default set
    if params[:licence_ids].nil?
      if @compatibility.licence.maintainer == 'Creative Commons'
        # show the matrix for other CC licences
        family_tree = @compatibility.licence.family_tree_nodes.first.family_tree
        @licences = family_tree.licences
      else
        # show the matrix for all licences of the same type
        if @compatibility.licence.domain_content
          @licences = Licence.where(domain_content: true)
        elsif @compatibility.licence.domain_software
          @licences = Licence.where(domain_software: true)
        elsif @compatibility.licence.domain_data
          @licences = Licence.where(domain_data: true)
        end
      end
      @licences.sort! {|a,b| a.identifier <=> b.identifier }
    end

    respond_to do |format|
      format.js
    end
  end

  private
  def find_compatibility
    if params[:id].match /\A\d+\Z/
      @compatibility = Compatibility.find(params[:id])
    else  #find by licence identifier
      licence = Licence.find_by_identifier(params[:id])
      @compatibility = licence.compatibility
    end
  end
end