# frozen_string_literal: true

class TicketLink < ApplicationRecord
  self.table_name = "ticket_links"

  belongs_to :blocking_ticket, class_name: "Ticket"
  belongs_to :blocked_ticket, class_name: "Ticket"

  validates :blocking_ticket_id, :blocked_ticket_id, presence: true
  validates :link_type, inclusion: { in: %w[impediment related] }
  validates :blocking_ticket_id, uniqueness: { scope: [ :blocked_ticket_id, :link_type ] }
  validate :cannot_link_to_itself

  enum :link_type, { impediment: 0, related: 1 }

  scope :impediments, -> { where(link_type: :impediment) }
  scope :related, -> { where(link_type: :related) }

  def cannot_link_to_itself
    return if blocking_ticket_id != blocked_ticket_id

    errors.add(:base, "A ticket cannot be linked to itself")
  end
end
