# frozen_string_literal: true

class TicketCategory < ApplicationRecord
  has_many :tickets, dependent: :restrict_with_error
  has_many :custom_fields, class_name: "TicketCustomField", dependent: :destroy
  has_many :slas, dependent: :destroy
  belongs_to :parent, class_name: "TicketCategory", optional: true
  has_many :children, class_name: "TicketCategory", foreign_key: :parent_id, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:name) }

  def has_children?
    children.exists?
  end

  def all_descendants
    children.flat_map { |child| [ child ] + child.all_descendants }
  end
end
