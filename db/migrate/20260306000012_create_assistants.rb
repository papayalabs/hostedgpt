class CreateAssistants < ActiveRecord::Migration[8.0]
  def change
    create_table "assistants" do |t|
      t.bigint   "user_id",                null: false
      t.string   "name"
      t.string   "description"
      t.string   "instructions"
      t.jsonb    "tools",                  default: [], null: false
      t.datetime "deleted_at",             precision: nil
      t.text     "external_id",
                 comment: "The Backend AI's (e.g OpenAI) assistant id"
      t.string   "slug"

      # Provider / API service fields (formerly api_services)
      t.string   "provider_name",          null: false
      t.string   "driver",                 null: false,
                 comment: "What API spec does this service conform to, e.g. OpenAI or Anthropic"
      t.string   "url",                    null: false
      t.string   "token"

      # Language model fields (formerly language_models)
      t.string   "api_name",               null: false,
                 comment: "This is the name that API calls are expecting."
      t.boolean  "supports_images",        null: false, default: false
      t.boolean  "supports_tools",         default: false
      t.boolean  "supports_system_message", default: false
      t.boolean  "supports_pdf",           default: false, null: false

      t.timestamps
    end

    add_index "assistants", ["external_id"],
              name: "index_assistants_on_external_id", unique: true
    add_index "assistants", ["user_id", "deleted_at"],
              name: "index_assistants_on_user_id_and_deleted_at"
    add_index "assistants", ["user_id", "slug"],
              name: "index_assistants_on_user_id_and_slug", unique: true,
              where: "(slug IS NOT NULL)"
    add_index "assistants", ["user_id"],
              name: "index_assistants_on_user_id"

    add_foreign_key "assistants", "users"
  end
end
