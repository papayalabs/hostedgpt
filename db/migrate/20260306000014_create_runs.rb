class CreateRuns < ActiveRecord::Migration[8.0]
  def change
    create_table "runs" do |t|
      t.bigint   "assistant_id",            null: false
      t.bigint   "conversation_id",         null: false
      t.string   "status",                  null: false
      t.jsonb    "required_action"
      t.jsonb    "last_error"
      t.datetime "expired_at",              precision: nil, null: false
      t.datetime "started_at",              precision: nil
      t.datetime "cancelled_at",            precision: nil
      t.datetime "failed_at",               precision: nil
      t.datetime "completed_at",            precision: nil
      t.string   "model",                   null: false
      t.string   "instructions"
      t.string   "additional_instructions"
      t.jsonb    "tools",                   default: [], null: false
      t.jsonb    "file_ids",                default: [], null: false
      t.text     "external_id",
                 comment: "The Backend AI system (e.g OpenAI) Run Id"
      t.timestamps
    end

    add_index "runs", ["assistant_id"],    name: "index_runs_on_assistant_id"
    add_index "runs", ["conversation_id"], name: "index_runs_on_conversation_id"

    add_foreign_key "runs", "assistants"
    add_foreign_key "runs", "conversations"
  end
end
