class ApplicationController < ActionController::Base
  protect_from_forgery

  # cancan acts on the current "Admin", if there is one
  def current_ability
    if !current_admin.nil?
      @current_ability ||= Ability.new(current_admin, params)
    else
      @current_ability ||= Ability.new(nil, params)
    end
  end
end
