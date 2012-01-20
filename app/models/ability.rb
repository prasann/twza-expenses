class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.superadmin?
      can :manage, :all 
    elsif user.admin?
      can :manage, :all
      cannot :create, @user
    else
      can :read, :all
    end
  end
end
