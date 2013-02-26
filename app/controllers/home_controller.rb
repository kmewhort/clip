class HomeController < ApplicationController
  def index
    @licences = Licence.all

    respond_to do |format|
      format.html
    end
  end
end