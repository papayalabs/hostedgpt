class CreateAuthentications < ActiveRecord::Migration[8.0]
  def change
    create_table "authentications" do |t|
      t.bigint   "credential_id", null: false
      t.bigint   "client_id",     null: false
      t.datetime "deleted_at",    precision: nil
      t.timestamps
    end

    add_index "authentications", ["client_id"],     name: "index_authentications_on_client_id"
    add_index "authentications", ["credential_id"], name: "index_authentications_on_credential_id"

    add_foreign_key "authentications", "clients"
    add_foreign_key "authentications", "credentials"
  end
end
