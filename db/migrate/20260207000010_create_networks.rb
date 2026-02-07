# frozen_string_literal: true

class CreateNetworks < ActiveRecord::Migration[8.0]
  def change
    create_table :networks do |t|
      t.string :name, null: false
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end

    add_index :networks, [ :name, :unit_id ], unique: true
  end
end
