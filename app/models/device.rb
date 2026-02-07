# frozen_string_literal: true

class Device < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :room, optional: true
  has_many :items, dependent: :nullify
  has_many :loans, as: :loanable, dependent: :destroy

  validates :asset_tag, presence: true, uniqueness: true
  validates :serial_number, presence: true, uniqueness: true
  validates :device_type, presence: true

  enum :device_type, {
    computer: 0,
    printer: 1,
    network_equipment: 2,
    server: 3,
    peripheral: 4,
    other: 5
  }

  enum :status, { active: 0, inactive: 1, maintenance: 2, decommissioned: 3 }
  scope :active, -> { where(status: :active) }
  scope :inactive, -> { where(status: :inactive) }
  scope :in_maintenance, -> { where(status: :maintenance) }
  scope :by_type, ->(type) { where(device_type: type) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :in_room, ->(room) { where(room_id: room.id) }
  scope :ordered, -> { order(:asset_tag) }

  def available?
    status == "active"
  end

  def decommission!
    update(status: :decommissioned, decommissioned_at: Time.current)
  end

  def return_to_service!
    update(status: :active, decommissioned_at: nil)
  end
end
