class ToolsController < ApplicationController
  def benchmark
  end

  def compare
    if params[:licence_a] && params[:licence_b]
      @licence_a = Licence.find(params[:id]) if params[:id]
      @licence_b = Licence.find(params[:compare_to_id]) if params[:compare_to_id]

      # render/cache an HTML diff of the two licences
      @comparison = @licence_a.html_diff_with(@licence_b)
    end

    if params[:family_tree_id]
      @family_tree = FamilyTree.find(params[:family_tree])
    end

    respond_to do |format|
      format.html
    end
  end
end