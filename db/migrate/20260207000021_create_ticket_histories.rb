# frozen_string_literal: true

class CreateTicketHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_histories do |t|
      t.string :action, null: false
      t.json :details, default: {}
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ticket_histories, :action
  end
end
