class CircularDependency
  attr_accessor :user

  def initialize(user)
    @user = user
  end
end
