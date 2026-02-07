# frozen_string_literal: true

class CreateTeamMembers < ActiveRecord::Migration[8.0]
  def change
    create_join_table :teams, :users, table_name: :team_members do |t|
      t.index [ :team_id, :user_id ], unique: true
      t.index [ :user_id, :team_id ], unique: true
    end
  end
end
