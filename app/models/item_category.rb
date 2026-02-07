# frozen_string_literal: true

class ItemCategory < ApplicationRecord
  has_many :items, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
end
