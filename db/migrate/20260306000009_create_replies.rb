class CreateReplies < ActiveRecord::Migration[8.0]
  def change
    create_table "replies" do |t|
      t.text   "content"
      t.bigint "note_id", null: false
      t.timestamps
    end

    add_index "replies", ["note_id"], name: "index_replies_on_note_id"

    add_foreign_key "replies", "notes"
  end
end
