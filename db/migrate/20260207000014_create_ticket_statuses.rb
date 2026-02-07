# frozen_string_literal: true

class CreateTicketStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_statuses do |t|
      t.string :name, null: false
      t.boolean :is_final, default: false
      t.boolean :is_closed, default: false

      t.timestamps
    end

    add_index :ticket_statuses, :name, unique: true
  end
end
