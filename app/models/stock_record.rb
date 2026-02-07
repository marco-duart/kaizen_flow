# frozen_string_literal: true

class StockRecord < ApplicationRecord
  self.table_name = "stock_records"

  belongs_to :item
  belongs_to :user, optional: true

  validates :item_id, presence: true
  validates :movement_type, presence: true, inclusion: { in: %w[in out adjustment consumption] }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  enum :movement_type, { in: 0, out: 1, adjustment: 2, consumption: 3 }

  scope :inbound, -> { where(movement_type: :in) }
  scope :outbound, -> { where(movement_type: :out) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_item, ->(item) { where(item_id: item.id) }
  scope :for_user, ->(user) { where(user_id: user.id) }

  attribute :notes, :text

  def self.in_quantity(item)
    inbound.for_item(item).sum(:quantity)
  end

  def self.out_quantity(item)
    outbound.for_item(item).sum(:quantity)
  end
end
