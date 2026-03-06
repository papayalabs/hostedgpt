class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table "notes" do |t|
      t.text    "content"
      t.bigint  "chat_id",   null: false
      t.integer "parent_id"
      t.timestamps
    end

    add_index "notes", ["chat_id"],   name: "index_notes_on_chat_id"
    add_index "notes", ["parent_id"], name: "index_notes_on_parent_id"

    add_foreign_key "notes", "chats"
  end
end
