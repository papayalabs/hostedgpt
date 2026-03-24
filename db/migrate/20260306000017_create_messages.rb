class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table "messages" do |t|
      t.bigint   "conversation_id",        null: false
      t.string   "role",                   null: false
      t.string   "content_text"
      t.bigint   "content_document_id"
      t.bigint   "run_id"
      t.bigint   "assistant_id",           null: false
      t.datetime "cancelled_at"
      t.datetime "processed_at",           precision: nil
      t.integer  "index",                  null: false
      t.integer  "version",                null: false
      t.boolean  "branched",               default: false, null: false
      t.integer  "branched_from_version"
      t.jsonb    "content_tool_calls"
      t.string   "tool_call_id"
      t.integer  "input_token_count",      default: 0, null: false
      t.integer  "output_token_count",     default: 0, null: false
      t.decimal  "input_token_cost",       precision: 30, scale: 15,
                                           default: "0.0", null: false
      t.decimal  "output_token_cost",      precision: 30, scale: 15,
                                           default: "0.0", null: false
      t.timestamps
    end

    add_index "messages", ["assistant_id"],
              name: "index_messages_on_assistant_id"
    add_index "messages", ["content_document_id"],
              name: "index_messages_on_content_document_id"
    add_index "messages", ["conversation_id", "index", "version"],
              name: "index_messages_on_conversation_id_and_index_and_version",
              unique: true
    add_index "messages", ["conversation_id"],
              name: "index_messages_on_conversation_id"
    add_index "messages", ["index"],
              name: "index_messages_on_index"
    add_index "messages", ["run_id"],
              name: "index_messages_on_run_id"
    add_index "messages", ["updated_at"],
              name: "index_messages_on_updated_at"
    add_index "messages", ["version"],
              name: "index_messages_on_version"

    add_foreign_key "messages", "assistants"
    add_foreign_key "messages", "conversations"
    add_foreign_key "messages", "runs"
    add_foreign_key "messages", "documents",
                    column: "content_document_id"

    # Circular FK dependencies resolved here
    add_foreign_key "users", "messages",
                    column: "last_cancelled_message_id"
    add_foreign_key "conversations", "messages",
                    column: "last_assistant_message_id"
    add_foreign_key "documents", "messages"
  end
end
