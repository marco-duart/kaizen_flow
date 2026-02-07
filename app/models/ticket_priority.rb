# frozen_string_literal: true

class TicketPriority < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  scope :ordered, -> { order(:level) }
  scope :highest_first, -> { order(level: :desc) }

  def self.critical
    find_by(name: "Critical")
  end

  def self.high
    find_by(name: "High")
  end

  def self.medium
    find_by(name: "Medium")
  end

  def self.low
    find_by(name: "Low")
  end
end
