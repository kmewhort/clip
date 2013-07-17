class CompatibilitiesController < ApplicationController
  before_filter :find_compatibility

  # matrix of two-way compatibilities
  def matrix
    # if no other licences are specified for compatibility determination, select a default set
    if !@compatibility.nil? && (params[:licence_ids].nil? || params[:licence_ids].empty?)
      # for CC licences, seed with other CC licences of the same version, plus CC0
      if @compatibility.licence.maintainer == 'Creative Commons'
        @licences = Licence.where(maintainer: 'Creative Commons', version: @compatibility.licence.version)
        if @compatibility.licence.identifier != 'CC0-1.0'
          @licences += [Licence.find_by_identifier('CC0-1.0')]
        else
          @licences += Licence.where(maintainer: 'Creative Commons', version: "3.0")
        end
      # for software licences, seed with a few commonly used licences
      elsif @compatibility.licence.domain_software
        @licences = [@compatibility.licence] + Licence.where(
          ['BSD-2-Clause','BSD-3-Clause''GPL-2.0+','GPL-3.0+','LGPL-2.1+','AGPL-3.0+'].map{|i| "identifier = '#{i}'"}.join(" OR "))
      # for data licences, seed with a few commonly used licences and also
      # show others in the same family
      elsif @compatibility.licence.domain_data
        @licences = [@compatibility.licence]
        @licences += @compatibility.licence.family_trees.first.licences unless @compatibility.licence.family_trees.empty?
        @licences += Licence.where(['CC0','CC-BY-3.0','ODC-PDDL-1.0','ODC-By-1.0','ODC-ODbL-1.0'].map{|i| "identifier = '#{i}'"}.join(" OR "))
      # for content licences, seed with a few commonly used and others in the same family
      elsif @compatibility.licence.domain_content
        @licences = [@compatibility.licence]
        @licences += @compatibility.licence.family_trees.first.licences unless @compatibility.licence.family_trees.empty?
        @licences += Licence.where(['CC0','CC-BY-3.0'].map{|i| "identifier = '#{i}'"}.join(" OR "))
      end
      @licences.sort! {|a,b| a.identifier <=> b.identifier }.uniq!
    # if a list of licences is specified, find each by compatibility id or licence identifier
    elsif !params[:licence_ids].nil?
      @licences = params[:licence_ids].map { |id| find_licence_by_compatibility_id(id) }.compact.uniq
    else
      @licences = []
    end

    respond_to do |format|
      format.js
    end
  end

  # table of compatibility where works under multiple different licences are remixed
  def multi_licence_chart
    @original_licences = params[:original_licence_ids].map { |id| find_licence_by_compatibility_id(id) }.uniq
    @target_licences = params[:target_licence_ids].map { |id| find_licence_by_compatibility_id(id) }.uniq
    @remix_type = params[:remix_type]

    respond_to do |format|
      format.js
    end
  end

  private
  def find_compatibility
    if params[:id]
      if params[:id].match /\A\d+\Z/
        @compatibility = Compatibility.find(params[:id])
      else  #find by licence identifier
        licence = Licence.find_by_identifier(params[:id])
        @compatibility = licence.compatibility
      end
    end
  end

  def find_licence_by_compatibility_id(id)
    if id.nil? || id.empty?
      nil
    else
      if id.match /\A\d+\Z/
        Compatibility.find(id).licence
      else  #find by licence identifier
        Licence.find_by_identifier(id)
      end
    end
  end
end