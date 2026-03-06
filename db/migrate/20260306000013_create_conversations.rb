# conversations.last_assistant_message_id references messages — foreign key added
# later in 20260306000035_add_circular_foreign_keys.rb to avoid circular dependency.
class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table "conversations" do |t|
      t.bigint   "user_id",                    null: false
      t.bigint   "assistant_id",               null: false
      t.string   "title"
      t.bigint   "last_assistant_message_id"
      t.text     "external_id",
                 comment: "The Backend AI system (e.g OpenAI) Thread Id"
      t.integer  "input_token_total_count",    default: 0, null: false
      t.integer  "output_token_total_count",   default: 0, null: false
      t.string   "share_token"
      t.timestamps
    end

    add_index "conversations", ["assistant_id"],
              name: "index_conversations_on_assistant_id"
    add_index "conversations", ["external_id"],
              name: "index_conversations_on_external_id", unique: true
    add_index "conversations", ["last_assistant_message_id"],
              name: "index_conversations_on_last_assistant_message_id"
    add_index "conversations", ["share_token"],
              name: "index_conversations_on_share_token"
    add_index "conversations", ["updated_at"],
              name: "index_conversations_on_updated_at"
    add_index "conversations", ["user_id"],
              name: "index_conversations_on_user_id"

    add_foreign_key "conversations", "assistants"
    add_foreign_key "conversations", "users"
  end
end
