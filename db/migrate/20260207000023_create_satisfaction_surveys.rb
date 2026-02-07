# frozen_string_literal: true

class CreateSatisfactionSurveys < ActiveRecord::Migration[8.0]
  def change
    create_table :satisfaction_surveys do |t|
      t.integer :rating, null: false
      t.text :comment
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end

    add_index :satisfaction_surveys, :rating
  end
end
