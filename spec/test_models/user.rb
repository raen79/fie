class User
  include ActiveModel::Model
  attr_accessor :name, :age, :circular_dependency

  def initialize(**kwargs)
    super(kwargs)
    @circular_dependency = CircularDependency.new(self)
  end
end
