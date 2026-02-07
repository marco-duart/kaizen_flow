# frozen_string_literal: true

class CreateSlas < ActiveRecord::Migration[8.0]
  def change
    create_table :slas do |t|
      t.string :name, null: false
      t.integer :target_resolution_time_minutes, null: false
      t.references :ticket_category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :slas, :name, unique: true
  end
end
