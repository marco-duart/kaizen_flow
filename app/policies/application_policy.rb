# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_has_permission?(:view)
  end

  def show?
    user_has_permission?(:view) && accessible_scope.include?(record)
  end

  def create?
    user_has_permission?(:create)
  end

  def new?
    create?
  end

  def update?
    user_has_permission?(:edit) && accessible_scope.include?(record)
  end

  def edit?
    update?
  end

  def destroy?
    user_has_permission?(:delete) && accessible_scope.include?(record)
  end

  def admin?
    user&.admin?
  end

  def agent?
    user&.agent?
  end

  def supervisor?
    user&.supervisor?
  end

  def end_user?
    user&.end_user?
  end

  protected

  def user_has_permission?(action)
    return true if admin?

    resource = record.is_a?(Class) ? record.name.underscore : record.class.name.underscore
    permission = user.role.permissions.find_by(resource: resource, action: action)

    permission.present?
  end

  def accessible_scope
    case permission_level
    when :own_record
      [ record ].select { |r| r.user_id == user.id }
    when :own_department
      filter_by_department
    when :own_unit
      filter_by_unit
    when :all
      Scope.new(user, record.class).resolve
    else
      []
    end
  end

  def permission_level
    resource = record.is_a?(Class) ? record.name.underscore : record.class.name.underscore
    permission = user.role.permissions.find_by(resource: resource)
    permission&.level&.to_sym || :own_record
  end

  def filter_by_department
    if record.respond_to?(:user) && record.user&.department_id == user.department_id
      [ record ]
    elsif record.respond_to?(:department_id) && record.department_id == user.department_id
      [ record ]
    else
      []
    end
  end

  def filter_by_unit
    if record.respond_to?(:unit_id) && record.unit_id == user.unit_id
      [ record ]
    else
      []
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.admin?

      case user.role.name
      when "agent"
        scope.where(assigned_to: user).or(scope.where(created_by: user))
      when "supervisor"
        scope.where(department: user.department)
      when "end_user"
        scope.where(created_by: user)
      else
        scope.none
      end
    end
  end
end
