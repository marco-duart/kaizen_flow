# frozen_string_literal: true

class Group < ApplicationRecord
  has_and_belongs_to_many :rooms, join_table: :group_rooms
  has_and_belongs_to_many :users, join_table: :user_groups

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :ordered, -> { order(:name) }
  scope :with_members, -> { includes(:users, :rooms) }
end
