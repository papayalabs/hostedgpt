class CreateMemories < ActiveRecord::Migration[8.0]
  def change
    create_table "memories" do |t|
      t.bigint "user_id",    null: false
      t.bigint "message_id"
      t.string "detail"
      t.timestamps
    end

    add_index "memories", ["message_id"], name: "index_memories_on_message_id"
    add_index "memories", ["user_id"],    name: "index_memories_on_user_id"

    add_foreign_key "memories", "messages"
    add_foreign_key "memories", "users"
  end
end
