# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.integer :failed_attempts, default: 0
      t.string :unlock_token
      t.datetime :locked_at

      t.string :full_name, null: false
      t.integer :status, default: 0, null: false
      t.boolean :is_online, default: false
      t.references :role, null: false, foreign_key: true
      t.references :department, foreign_key: true

      t.string :provider, default: "email", null: false
      t.string :uid, default: "", null: false
      t.json :tokens

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [ :uid, :provider ], unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token, unique: true
  end
end
