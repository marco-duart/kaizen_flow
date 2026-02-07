# frozen_string_literal: true

class CreateTicketTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.references :ticket, null: false, foreign_key: true
      t.datetime :completed_at

      t.timestamps
    end

    add_index :ticket_tasks, :status
  end
end
