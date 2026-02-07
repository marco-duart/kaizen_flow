# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :category, class_name: "TicketCategory"
  belongs_to :status, class_name: "TicketStatus"
  belongs_to :priority, class_name: "TicketPriority"
  belongs_to :unit
  belongs_to :room, optional: true

  has_many :comments, dependent: :destroy
  has_many :tasks, class_name: "TicketTask", dependent: :destroy
  has_many :blocking_links, class_name: "TicketLink", foreign_key: :blocking_ticket_id, dependent: :destroy
  has_many :blocked_by_links, class_name: "TicketLink", foreign_key: :blocked_ticket_id, dependent: :destroy
  has_many :ticket_histories, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_one_attached :file

  validates :subject, presence: true, length: { minimum: 5, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :requester_id, :category_id, :status_id, :priority_id, :unit_id, presence: true

  scope :open, -> { joins(:status).where(ticket_statuses: { is_closed: false }) }
  scope :closed, -> { joins(:status).where(ticket_statuses: { is_closed: true }) }
  scope :assigned, -> { where.not(assignee_id: nil) }
  scope :unassigned, -> { where(assignee_id: nil) }
  scope :for_requester, ->(user) { where(requester_id: user.id) }
  scope :for_assignee, ->(user) { where(assignee_id: user.id) }
  scope :for_unit, ->(unit) { where(unit_id: unit.id) }
  scope :for_category, ->(category) { where(category_id: category.id) }
  scope :by_priority, ->(priority) { where(priority_id: priority.id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  store :custom_data, accessors: [], coder: JSON

  before_create :set_ticket_number
  after_create :record_creation_history

  def set_ticket_number
    self.ticket_number = "TICKET-#{Time.current.year}-#{SecureRandom.hex(4).upcase}"
  end

  def record_creation_history
    TicketHistory.create(
      ticket_id: id,
      user_id: requester_id,
      action: "created",
      details: { subject: subject, priority: priority.name }
    )
  end

  def blocked?
    blocked_by_links.exists?
  end

  def blocking?
    blocking_links.exists?
  end

  def sla
    category.slas.first
  end

  def sla_deadline
    sla.present? ? created_at + sla.target_resolution_time_minutes.minutes : nil
  end

  def sla_expired?
    sla_deadline&.<(Time.current) || false
  end

  def sla_warning?(threshold = 0.8)
    return false unless sla_deadline

    time_remaining = sla_deadline - Time.current
    total_time = sla.target_resolution_time_minutes * 60
    time_remaining < (total_time * (1 - threshold))
  end

  def reopen!
    reopened_status = TicketStatus.find_by(name: "Reopened") || TicketStatus.active.first
    update(status_id: reopened_status.id) if reopened_status
  end
end
