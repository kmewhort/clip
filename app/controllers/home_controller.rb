class HomeController < ApplicationController
  def index
    @licences = Licence.all(order: :title)

    respond_to do |format|
      format.html
    end
  end

  def api
  end
end