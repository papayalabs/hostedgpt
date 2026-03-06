class CreateTombstones < ActiveRecord::Migration[8.0]
  def change
    create_table "tombstones" do |t|
      t.datetime "erected_at"
    end
  end
end
