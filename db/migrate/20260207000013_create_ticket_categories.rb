# frozen_string_literal: true

class CreateTicketCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_categories do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.references :parent, foreign_key: { to_table: :ticket_categories }

      t.timestamps
    end

    add_index :ticket_categories, :name, unique: true
  end
end
