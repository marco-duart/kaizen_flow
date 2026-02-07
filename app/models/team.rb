# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :department
  has_and_belongs_to_many :users, join_table: :team_members

  validates :name, presence: true, uniqueness: true
  validates :department_id, presence: true

  scope :ordered, -> { order(:name) }
  scope :with_members, -> { includes(:users) }
end
