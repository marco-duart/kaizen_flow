# frozen_string_literal: true

class CreateTicketLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_links do |t|
      t.references :blocking_ticket, foreign_key: { to_table: :tickets }, null: false
      t.references :blocked_ticket, foreign_key: { to_table: :tickets }, null: false
      t.integer :link_type, default: 0, null: false

      t.timestamps
    end

    add_index :ticket_links, [ :blocking_ticket_id, :blocked_ticket_id, :link_type ], unique: true
  end
end
