# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.text :description
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end

    add_index :teams, :name, unique: true
  end
end
