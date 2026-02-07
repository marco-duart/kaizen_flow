# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :role

  validates :resource, :action, :level, presence: true
  validates :resource, uniqueness: { scope: [ :action, :level, :role_id ] }

  RESOURCES = %w[ticket user company unit room group device item loan comment ticket_category
                 ticket_status ticket_priority sla ticket_schedule].freeze
  ACTIONS = %w[view create edit delete].freeze
  LEVELS = %w[own_record own_department own_unit all_records].freeze

  enum :level, { own_record: 0, own_department: 1, own_unit: 2, all_records: 3 }

  validates :resource, inclusion: { in: RESOURCES }
  validates :action, inclusion: { in: ACTIONS }

  scope :for_resource, ->(resource) { where(resource: resource) }
  scope :for_action, ->(action) { where(action: action) }
  scope :ordered, -> { order(:resource, :action, :level) }
end
