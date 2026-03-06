class CreateAPIServices < ActiveRecord::Migration[8.0]
  def change
    create_table "api_services" do |t|
      t.bigint   "user_id",    null: false
      t.string   "name",       null: false
      t.string   "driver",     null: false,
                 comment: "What API spec does this service conform to, e.g. OpenAI or Anthropic"
      t.string   "url",        null: false
      t.string   "token"
      t.datetime "deleted_at", precision: nil
      t.timestamps
    end

    add_index "api_services", ["user_id", "deleted_at"],
              name: "index_api_services_on_user_id_and_deleted_at"
    add_index "api_services", ["user_id"],
              name: "index_api_services_on_user_id"

    add_foreign_key "api_services", "users"
  end
end
