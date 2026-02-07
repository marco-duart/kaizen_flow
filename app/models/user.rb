# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  include DeviseTokenAuth::Concerns::User

  belongs_to :role
  belongs_to :department, optional: true
  has_and_belongs_to_many :groups, join_table: :user_groups
  has_and_belongs_to_many :teams, join_table: :team_members
  has_many :created_tickets, class_name: "Ticket", foreign_key: :requester_id, dependent: :nullify
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :ticket_histories, dependent: :destroy
  has_many :devices, dependent: :nullify
  has_many :stock_records, dependent: :nullify
  has_many :loans, dependent: :nullify

  validates :email, presence: true, uniqueness: true
  validates :full_name, presence: true

  enum :status, { active: 0, inactive: 1, suspended: 2 }

  scope :active, -> { where(status: :active) }
  scope :by_role, ->(role) { where(role_id: role.id) }
  scope :by_department, ->(department) { where(department_id: department.id) }
  scope :ordered, -> { order(:full_name) }

  def display_name
    full_name.presence || email.split("@").first
  end

  def deactivate!
    update(status: :inactive)
  end

  def activate!
    update(status: :active)
  end

  def admin?
    role.name == "admin"
  end

  def agent?
    role.name == "agent"
  end

  def supervisor?
    role.name == "supervisor"
  end

  def end_user?
    role.name == "end_user"
  end
end
