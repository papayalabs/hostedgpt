class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table "people" do |t|
      t.string "personable_type"
      t.bigint "personable_id"
      t.string "email"
      t.timestamps
    end

    add_index "people", ["email"], name: "index_people_on_email", unique: true
    add_index "people", ["personable_type", "personable_id"], name: "index_people_on_personable"
  end
end
