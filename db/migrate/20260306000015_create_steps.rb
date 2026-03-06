class CreateSteps < ActiveRecord::Migration[8.0]
  def change
    create_table "steps" do |t|
      t.bigint   "assistant_id",    null: false
      t.bigint   "conversation_id", null: false
      t.bigint   "run_id",          null: false
      t.string   "kind",            null: false
      t.string   "status",          null: false
      t.jsonb    "details",         null: false
      t.jsonb    "last_error"
      t.datetime "expired_at",      precision: nil
      t.datetime "cancelled_at",    precision: nil
      t.datetime "failed_at",       precision: nil
      t.datetime "completed_at",    precision: nil
      t.text     "external_id",
                 comment: "The Backend AI system (e.g OpenAI) Step Id"
      t.timestamps
    end

    add_index "steps", ["assistant_id"],    name: "index_steps_on_assistant_id"
    add_index "steps", ["conversation_id"], name: "index_steps_on_conversation_id"
    add_index "steps", ["run_id"],          name: "index_steps_on_run_id"

    add_foreign_key "steps", "assistants"
    add_foreign_key "steps", "conversations"
    add_foreign_key "steps", "runs"
  end
end
