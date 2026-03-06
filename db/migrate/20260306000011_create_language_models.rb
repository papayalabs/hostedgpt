class CreateLanguageModels < ActiveRecord::Migration[8.0]
  def change
    create_table "language_models" do |t|
      t.integer  "position",               null: false
      t.string   "api_name",               null: false,
                 comment: "This is the name that API calls are expecting."
      t.string   "name",                   null: false
      t.boolean  "supports_images",        null: false
      t.boolean  "supports_tools",         default: false
      t.boolean  "supports_system_message", default: false
      t.boolean  "supports_pdf",           default: false, null: false
      t.datetime "deleted_at",             precision: nil
      t.bigint   "user_id",                null: false
      t.bigint   "api_service_id"
      t.timestamps
    end

    add_index "language_models", ["api_service_id"],
              name: "index_language_models_on_api_service_id"
    add_index "language_models", ["user_id", "deleted_at"],
              name: "index_language_models_on_user_id_and_deleted_at"
    add_index "language_models", ["user_id"],
              name: "index_language_models_on_user_id"

    add_foreign_key "language_models", "api_services"
    add_foreign_key "language_models", "users"
  end
end
