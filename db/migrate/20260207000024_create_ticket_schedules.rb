# frozen_string_literal: true

class CreateTicketSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_schedules do |t|
      t.string :name, null: false
      t.integer :frequency, default: 0, null: false
      t.date :start_date, null: false
      t.json :template_ticket_data, default: {}
      t.boolean :is_active, default: true
      t.datetime :last_run_at

      t.timestamps
    end

    add_index :ticket_schedules, :name, unique: true
    add_index :ticket_schedules, :is_active
  end
end
