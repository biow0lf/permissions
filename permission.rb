# frozen_string_literal: true

class User
  attr_reader :first_name, :last_name, :fired, :roles

  alias_method :fired?, :fired

  def initialize(params, roles = [])
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @fired = params[:fired]
    @roles = roles
  end

  def can?(action, resource)
    UserPermitter.new(self, action, resource).can?
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
  attr_reader :name, :permissions

  def initialize(name, permissions = [])
    @name = name
    @permissions = permissions
  end

  def add_permission(permission)
    @permissions << permission
  end
end

class ResourcePermission
  attr_reader :resource, :action

  def initialize(resource, action)
    @resource = resource
    @action = action
  end
end

class UserPermitter
  attr_reader :user, :action, :resource

  def initialize(user, action, resource)
    @user = user
    @action = action
    @resource = resource
  end

  def can?
    return false if user.fired?

    return true if can_via_roles

    return true if can_via_resource_permissions

    false
  end

  private

  def can_via_roles
    user.roles.each do |role|
      return true if role.action == action && role.resource == resource
    end

    false
  end

  def can_via_resource_permissions
    resource.permissions.each do |permission|
      return true if permission.action == action && permission.resource == resource
    end

    false
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

# Case 5: user can read Backoffice due global permission

params = { first_name: 'Igor', last_name: 'Zubkov' }

user = User.new(params)

action = 'read'

resource = Resource.new('Backoffice')

permission = ResourcePermission.new(resource, action)

resource.add_permission(permission)

val = user.can?(action, resource) # => true

puts val

assert(true, val)
