# frozen_string_literal: true

class CreateDevices < ActiveRecord::Migration[8.0]
  def change
    create_table :devices do |t|
      t.string :asset_tag, null: false
      t.string :serial_number, null: false
      t.integer :device_type, default: 5, null: false
      t.integer :status, default: 0, null: false
      t.references :user, foreign_key: true
      t.references :room, foreign_key: true
      t.datetime :decommissioned_at

      t.timestamps
    end

    add_index :devices, :asset_tag, unique: true
    add_index :devices, :serial_number, unique: true
    add_index :devices, :status
    add_index :devices, :device_type
  end
end
