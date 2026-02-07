# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :sku, null: false
      t.string :name, null: false
      t.integer :quantity, default: 0
      t.integer :reorder_point, default: 10, null: false
      t.json :category_attributes, default: {}
      t.references :category, foreign_key: { to_table: :item_categories }, null: false

      t.timestamps
    end

    add_index :items, :sku, unique: true
    add_index :items, :name
  end
end
