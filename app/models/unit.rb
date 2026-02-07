# frozen_string_literal: true

class Unit < ApplicationRecord
  belongs_to :company
  has_many :networks, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :tickets, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :company_id, presence: true
  validates :address, presence: true

  scope :ordered, -> { order(:name) }
  scope :for_company, ->(company) { where(company_id: company.id) }
end
