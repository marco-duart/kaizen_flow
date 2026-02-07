# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :ticket_number, null: false
      t.string :subject, null: false
      t.text :description, null: false
      t.json :custom_data, default: {}
      t.references :requester, foreign_key: { to_table: :users }, null: false
      t.references :assignee, foreign_key: { to_table: :users }
      t.references :category, foreign_key: { to_table: :ticket_categories }, null: false
      t.references :status, foreign_key: { to_table: :ticket_statuses }, null: false
      t.references :priority, foreign_key: { to_table: :ticket_priorities }, null: false
      t.references :unit, null: false, foreign_key: true
      t.references :room, foreign_key: true
      t.datetime :resolved_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :tickets, :ticket_number, unique: true
    add_index :tickets, [ :status_id, :assignee_id ]
    add_index :tickets, [ :status_id, :requester_id ]
  end
end
