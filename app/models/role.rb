# frozen_string_literal: true

class Role < ApplicationRecord
  belongs_to :company
  has_many :users, dependent: :nullify
  has_many :permissions, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :company_id, presence: true

  BUILT_IN_ROLES = %w[admin agent supervisor end_user].freeze

  scope :built_in, -> { where(name: BUILT_IN_ROLES) }
  scope :custom, -> { where.not(name: BUILT_IN_ROLES) }
  scope :ordered, -> { order(:name) }
end
