# frozen_string_literal: true

class Sla < ApplicationRecord
  self.table_name = "slas"

  belongs_to :ticket_category

  validates :name, presence: true, uniqueness: true
  validates :target_resolution_time_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :ticket_category_id, presence: true

  scope :ordered, -> { order(:name) }

  def resolution_time_hours
    target_resolution_time_minutes / 60.0
  end

  def resolution_time_days
    target_resolution_time_minutes / (60.0 * 24)
  end
end
