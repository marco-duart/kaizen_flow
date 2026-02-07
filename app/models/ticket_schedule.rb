# frozen_string_literal: true

class TicketSchedule < ApplicationRecord
  self.table_name = "ticket_schedules"

  has_many :tickets, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :frequency, presence: true, inclusion: { in: %w[daily weekly monthly quarterly yearly] }
  validates :start_date, presence: true
  validates :template_ticket_data, presence: true

  enum :frequency, { daily: 0, weekly: 1, monthly: 2, quarterly: 3, yearly: 4 }

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :ordered, -> { order(:name) }

  store :template_ticket_data, accessors: [], coder: JSON

  def next_due_date
    case frequency
    when "daily"
      start_date + 1.day
    when "weekly"
      start_date + 1.week
    when "monthly"
      start_date + 1.month
    when "quarterly"
      start_date + 3.months
    when "yearly"
      start_date + 1.year
    end
  end

  def should_generate_ticket?
    return false unless is_active

    Time.current >= next_due_date
  end

  def activate!
    update(is_active: true)
  end

  def deactivate!
    update(is_active: false)
  end
end
