# documents.message_id references messages — foreign key added later
# in 20260306000035_add_circular_foreign_keys.rb to avoid circular dependency.
class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table "documents" do |t|
      t.bigint  "user_id",      null: false
      t.bigint  "assistant_id"
      t.bigint  "message_id"
      t.string  "filename",     null: false
      t.string  "purpose",      null: false
      t.integer "bytes",        null: false
      t.timestamps
    end

    add_index "documents", ["assistant_id"], name: "index_documents_on_assistant_id"
    add_index "documents", ["message_id"],   name: "index_documents_on_message_id"
    add_index "documents", ["user_id"],      name: "index_documents_on_user_id"

    add_foreign_key "documents", "assistants"
    add_foreign_key "documents", "users"
  end
end
