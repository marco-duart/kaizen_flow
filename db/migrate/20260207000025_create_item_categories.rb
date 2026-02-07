# frozen_string_literal: true

class CreateItemCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :item_categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :item_categories, :name, unique: true
  end
end
