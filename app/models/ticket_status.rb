# frozen_string_literal: true

class TicketStatus < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :is_final, :is_closed, inclusion: { in: [ true, false ] }

  scope :active, -> { where(is_final: false, is_closed: false) }
  scope :final, -> { where(is_final: true) }
  scope :closed, -> { where(is_closed: true) }
  scope :ordered, -> { order(:name) }

  def terminal?
    is_final || is_closed
  end
end
