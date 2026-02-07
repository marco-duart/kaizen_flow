# frozen_string_literal: true

class Loan < ApplicationRecord
  belongs_to :user
  belongs_to :loanable, polymorphic: true

  validates :user_id, presence: true
  validates :loanable_id, :loanable_type, presence: true
  validates :due_date, presence: true
  validate :due_date_cannot_be_in_the_past

  scope :active, -> { where(returned_at: nil) }
  scope :returned, -> { where.not(returned_at: nil) }
  scope :overdue, -> { active.where("due_date < ?", Time.current) }
  scope :for_user, ->(user) { where(user_id: user.id) }
  scope :recent, -> { order(created_at: :desc) }

  def overdue?
    active? && due_date < Time.current
  end

  def active?
    returned_at.nil?
  end

  def days_until_due
    (due_date.to_date - Time.current.to_date).to_i
  end

  def return!
    update(returned_at: Time.current)
  end

  private

  def due_date_cannot_be_in_the_past
    return if due_date.blank?
    return if due_date >= Time.current

    errors.add(:due_date, "cannot be in the past")
  end
end
