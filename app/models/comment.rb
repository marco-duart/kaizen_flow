# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user
  has_one_attached :file

  validates :content, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :ticket_id, :user_id, presence: true
  validates :is_internal, inclusion: { in: [ true, false ] }

  enum :comment_type, { text: 0, system: 1, resolution: 2 }

  scope :public_comments, -> { where(is_internal: false) }
  scope :internal_comments, -> { where(is_internal: true) }
  scope :visible_to, ->(user) { where("is_internal = false OR user_id = ? OR ? = true", user.id, user.agent?) }
  scope :recent, -> { order(created_at: :desc) }
  scope :ordered, -> { order(created_at: :asc) }

  before_create :notify_participants

  private

  def notify_participants
    # Mailer?
  end
end
