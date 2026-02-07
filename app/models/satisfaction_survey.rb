# frozen_string_literal: true

class SatisfactionSurvey < ApplicationRecord
  self.table_name = "satisfaction_surveys"

  belongs_to :ticket

  validates :ticket_id, presence: true, uniqueness: true
  validates :rating, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  enum :rating, { very_dissatisfied: 1, dissatisfied: 2, neutral: 3, satisfied: 4, very_satisfied: 5 }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }

  def self.average_rating
    average(:rating).to_f.round(2)
  end

  def self.satisfaction_percentage
    total_surveys = count
    return 0 if total_surveys.zero?

    satisfied_surveys = where(rating: [ :satisfied, :very_satisfied ]).count
    ((satisfied_surveys.to_f / total_surveys) * 100).round(2)
  end
end
