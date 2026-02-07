# frozen_string_literal: true

class CreateGroupRooms < ActiveRecord::Migration[8.0]
  def change
    create_join_table :groups, :rooms, table_name: :group_rooms do |t|
      t.index [ :group_id, :room_id ], unique: true
      t.index [ :room_id, :group_id ], unique: true
    end
  end
end
