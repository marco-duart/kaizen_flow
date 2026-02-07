# frozen_string_literal: true

class CreateStockRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_records do |t|
      t.integer :movement_type, default: 0, null: false
      t.integer :quantity, null: false
      t.text :notes
      t.references :item, null: false, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :stock_records, :movement_type
  end
end
