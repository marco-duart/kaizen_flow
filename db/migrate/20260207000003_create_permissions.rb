# frozen_string_literal: true

class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :resource, null: false
      t.string :action, null: false
      t.integer :level, default: 0, null: false
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end

    add_index :permissions, [ :resource, :action, :level, :role_id ], unique: true
  end
end
