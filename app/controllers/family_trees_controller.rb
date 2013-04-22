class FamilyTreesController < ApplicationController
  def show
    @family_tree = FamilyTree.find(params[:id])

    respond_to do |format|
      format.html
      format.js
    end
  end
end
