# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :units, dependent: :destroy
  has_many :roles, dependent: :destroy

  validates :name, :cnpj, presence: true
  validates :cnpj, uniqueness: true, format: { with: /\A\d{14}\z/, message: "must be 14 digits" }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def deactivate!
    update(active: false)
  end

  def activate!
    update(active: true)
  end
end
