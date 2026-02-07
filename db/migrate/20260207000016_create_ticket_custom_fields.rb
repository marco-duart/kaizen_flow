# frozen_string_literal: true

class CreateTicketCustomFields < ActiveRecord::Migration[8.0]
  def change
    create_table :ticket_custom_fields do |t|
      t.string :name, null: false
      t.integer :field_type, default: 0, null: false
      t.boolean :is_required, default: false
      t.json :options, default: {}
      t.references :ticket_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ticket_custom_fields, [ :name, :ticket_category_id ], unique: true
  end
end
