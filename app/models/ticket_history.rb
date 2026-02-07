# frozen_string_literal: true

class TicketHistory < ApplicationRecord
  self.table_name = "ticket_histories"

  belongs_to :ticket
  belongs_to :user

  validates :ticket_id, :user_id, :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_ticket, ->(ticket) { where(ticket_id: ticket.id) }
  scope :by_action, ->(action_type) { where(action: action_type) }

  enum :action, {
    created: 0,
    status_changed: 1,
    assigned: 2,
    commented: 3,
    resolved: 4,
    reopened: 5,
    priority_changed: 6,
    category_changed: 7,
    closed: 8
  }
end
