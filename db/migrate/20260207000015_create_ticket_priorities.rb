# frozen_string_literal: true

class CreateTicketPriorities < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_priorities do |t|
      t.string :name, null: false
      t.integer :level, null: false

      t.timestamps
    end

    add_index :ticket_priorities, :name, unique: true
    add_index :ticket_priorities, :level
  end
end
