# frozen_string_literal: true

class TicketCustomField < ApplicationRecord
  self.table_name = "ticket_custom_fields"

  belongs_to :ticket_category

  validates :name, presence: true, uniqueness: { scope: :ticket_category_id }
  validates :field_type, presence: true, inclusion: { in: %w[text textarea select date checkbox] }
  validates :ticket_category_id, presence: true

  enum :field_type, {
    text: 0,
    textarea: 1,
    select: 2,
    date: 3,
    checkbox: 4
  }

  scope :required, -> { where(is_required: true) }
  scope :optional, -> { where(is_required: false) }
  scope :ordered, -> { order(:name) }
end
