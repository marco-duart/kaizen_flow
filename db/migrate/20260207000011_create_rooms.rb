# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.integer :location_type, default: 6, null: false
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end

    add_index :rooms, [ :name, :unit_id ], unique: true
    add_index :rooms, :location_type
  end
end
