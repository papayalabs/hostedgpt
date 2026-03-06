class CreateCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table "credentials" do |t|
      t.bigint   "user_id", null: false
      t.string   "type"
      t.string   "password_digest"
      t.string   "external_id",
                 comment: "Credential models will alias this for their purpose (e.g. Google and HTTP Header)"
      t.string   "oauth_email"
      t.string   "oauth_token"
      t.string   "oauth_refresh_token"
      t.jsonb    "properties"
      t.datetime "last_authenticated_at", precision: nil
      t.timestamps
    end

    add_index "credentials", ["external_id"],
              name: "index_credentials_on_external_id"
    add_index "credentials", ["type", "external_id"],
              name: "index_credentials_on_type_and_external_id", unique: true
    add_index "credentials", ["type", "oauth_email"],
              name: "index_credentials_on_type_and_oauth_email", unique: true
    add_index "credentials", ["user_id"],
              name: "index_credentials_on_user_id"

    add_foreign_key "credentials", "users"
  end
end
