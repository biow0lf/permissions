# frozen_string_literal: true

class User
  attr_reader :first_name, :last_name, :fired, :roles

  def initialize(params, roles = [])
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @fired = params[:fired] || false
    @roles = roles
  end

  def can?(action, resource)
    return false if fired

    roles.each do |role|
      if role.action == action && role.resource == resource
        return true
      end
    end

    false
  end

  def add_role(role)
    roles << role
  end

  def fire!
    @fired = true
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

# Case 1: user fired

params = { first_name: 'Igor', last_name: 'Zubkov', fired: true }

user = User.new(params)

action = 'read'

resource = Resource.new('Backoffice')

val = user.can?(action, resource) # => false

puts val

assert(false, val)

# Case 2: user can't read Backoffice

params = { first_name: 'Igor', last_name: 'Zubkov' }

user = User.new(params)

action = 'read'

resource = Resource.new('Backoffice')

val = user.can?(action, resource) # => false

puts val

assert(false, val)

# Case 3: user can read Backoffice due role "Read backoffice"

params = { first_name: 'Igor', last_name: 'Zubkov' }

user = User.new(params)

action = 'read'

resource = Resource.new('Backoffice')

role = Role.new('Read backoffice', 'read', resource)

user.add_role(role)

val = user.can?(action, resource) # => true

puts val

assert(true, val)

# Case 4: user can't read Backoffice if fired

user.fire!

val = user.can?(action, resource) # => true

puts val

assert(false, val)
