# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description, null: false

      t.timestamps
    end

    add_index :groups, :name, unique: true

    create_join_table :groups, :users, table_name: :user_groups do |t|
      t.index [ :group_id, :user_id ], unique: true
      t.index [ :user_id, :group_id ], unique: true
    end
  end
end
