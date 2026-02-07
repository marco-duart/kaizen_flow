# frozen_string_literal: true

class TicketTask < ApplicationRecord
  self.table_name = "ticket_tasks"

  belongs_to :ticket

  validates :title, presence: true, length: { minimum: 3, maximum: 255 }
  validates :ticket_id, presence: true

  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }

  scope :completed, -> { where(status: :completed) }
  scope :pending, -> { where(status: :pending) }
  scope :ordered, -> { order(:created_at) }

  def complete!
    update(status: :completed, completed_at: Time.current)
  end

  def completion_percentage
    return 0 if ticket.tasks.empty?

    (ticket.tasks.completed.count.to_f / ticket.tasks.count * 100).round(2)
  end
end
