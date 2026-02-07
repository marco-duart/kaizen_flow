# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :unit
  has_many :devices, dependent: :nullify
  has_and_belongs_to_many :groups, join_table: :group_rooms
  has_many :tickets, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :unit_id }
  validates :unit_id, presence: true
  validates :location_type, presence: true

  enum :location_type, {
    classroom: 0,
    laboratory: 1,
    office: 2,
    server_room: 3,
    storage: 4,
    common_area: 5,
    other: 6
  }

  scope :ordered, -> { order(:name) }
  scope :for_unit, ->(unit) { where(unit_id: unit.id) }
  scope :by_type, ->(type) { where(location_type: type) }
end
