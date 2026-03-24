# users.last_cancelled_message_id references messages — foreign key added later
# in 20260306000035_add_circular_foreign_keys.rb to avoid circular dependency.
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table "users" do |t|
      t.datetime "registered_at", default: -> { "CURRENT_TIMESTAMP" }
      t.string   "first_name", null: false
      t.string   "last_name"
      t.string   "email"
      t.string   "password_digest"
      t.jsonb    "preferences"
      t.bigint   "last_cancelled_message_id"
    end

    add_index "users", ["email"],
              name: "index_users_on_email", unique: true
    add_index "users", ["last_cancelled_message_id"],
              name: "index_users_on_last_cancelled_message_id"
  end
end
