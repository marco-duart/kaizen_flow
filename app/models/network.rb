# frozen_string_literal: true

class Network < ApplicationRecord
  belongs_to :unit

  validates :name, presence: true, uniqueness: { scope: :unit_id }
  validates :unit_id, presence: true

  scope :ordered, -> { order(:name) }
  scope :for_unit, ->(unit) { where(unit_id: unit.id) }
end
