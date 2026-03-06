class CreateChats < ActiveRecord::Migration[8.0]
  def change
    create_table "chats" do |t|
      t.string  "name"
      t.bigint  "user_id", null: false
      t.timestamps
    end

    add_index "chats", ["user_id"], name: "index_chats_on_user_id"

    add_foreign_key "chats", "users"
  end
end
