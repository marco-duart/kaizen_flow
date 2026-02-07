# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :category, class_name: "ItemCategory"
  has_many :stock_records, dependent: :destroy
  has_many :devices, dependent: :nullify
  has_many :loans, as: :loanable, dependent: :destroy

  validates :sku, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :reorder_point, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category_id, presence: true

  store :category_attributes, accessors: [], coder: JSON

  scope :ordered, -> { order(:name) }
  scope :low_stock, -> { where("quantity <= reorder_point") }
  scope :for_category, ->(category) { where(category_id: category.id) }

  def in_stock?
    quantity.positive?
  end

  def low_stock?
    quantity <= reorder_point
  end

  def available_quantity
    [ quantity, 0 ].max
  end

  def reserve!(amount)
    return false if available_quantity < amount

    update(quantity: quantity - amount)
  end

  def restock!(amount)
    update(quantity: quantity + amount)
  end
end
