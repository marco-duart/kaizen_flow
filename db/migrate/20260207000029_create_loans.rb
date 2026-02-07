# frozen_string_literal: true

class CreateLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :loanable_type, null: false
      t.bigint :loanable_id, null: false
      t.date :due_date, null: false
      t.datetime :returned_at

      t.timestamps
    end

    add_index :loans, [ :loanable_type, :loanable_id ]
    add_index :loans, :due_date
  end
end
