# frozen_string_literal: true

class User
  attr_reader :first_name, :last_name, :roles

  def initialize(params, roles = [])
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @roles = roles
  end

  def can?(action, resource)
    roles.include?("#{ action }": resource)
  end

  def add_role(role)
    roles << role
  end
end

class Role
  attr_reader :name, :action, :resource

  def initialize(name, action, resource)
    @name = name
    @action = action
    @resource = resource
  end
end

class Resource
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

def assert(expect, actual)
  raise "Actual result '#{ actual }' different from expected '#{ expect }'" if expect != actual
end

params = { first_name: 'Igor', last_name: 'Zubkov' }

user = User.new(params)

action = 'read'

resource = Resource.new('Backoffice')

val = user.can?(action, resource) # => false

puts val

assert(false, val)

role = Role.new('Read backoffice', 'read', resource)

user.add_role(role)

val = user.can?(action, resource) # => true

puts val

assert(true, val)
