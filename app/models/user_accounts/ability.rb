class Ability
  include CanCan::Ability

  def initialize(user, params)
    # guests can read all information
    can :read, :all
    can :compare_to, Licence

    # guests can preview json and submit updates in a non-saving "submit_for_review" mode
    can [:new, :edit], Licence
    can [:create, :update], Licence if params[:preview] || params[:submit_for_review]

    # admins can do everything
    if !user.nil?
      can :manage, :all
    end
  end
end
