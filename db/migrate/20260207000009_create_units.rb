# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :units, [ :name, :company_id ], unique: true
  end
end
