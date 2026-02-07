# frozen_string_literal: true

class Department < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :teams, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
end
