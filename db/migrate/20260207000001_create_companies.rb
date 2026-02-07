# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :cnpj, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :companies, :cnpj, unique: true
  end
end
