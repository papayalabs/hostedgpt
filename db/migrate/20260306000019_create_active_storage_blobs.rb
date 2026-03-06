class CreateActiveStorageBlobs < ActiveRecord::Migration[8.0]
  def change
    # active_storage_blobs — must exist before attachments and variant_records
    create_table "active_storage_blobs" do |t|
      t.string   "key",          null: false
      t.string   "filename",     null: false
      t.string   "content_type"
      t.text     "metadata"
      t.string   "service_name", null: false
      t.bigint   "byte_size",    null: false
      t.string   "checksum"
      t.datetime "created_at",   null: false
    end

    add_index "active_storage_blobs", ["key"],
              name: "index_active_storage_blobs_on_key", unique: true

    # active_storage_files — PostgreSQL-backed large object tracking
    create_table "active_storage_files" do |t|
      t.oid    "oid"
      t.string "key"
    end

    add_index "active_storage_files", ["key"],
              name: "index_active_storage_files_on_key", unique: true

    # active_storage_attachments — polymorphic join between records and blobs
    create_table "active_storage_attachments" do |t|
      t.string   "name",        null: false
      t.string   "record_type", null: false
      t.bigint   "record_id",   null: false
      t.bigint   "blob_id",     null: false
      t.datetime "created_at",  null: false
    end

    add_index "active_storage_attachments", ["blob_id"],
              name: "index_active_storage_attachments_on_blob_id"
    add_index "active_storage_attachments",
              ["record_type", "record_id", "name", "blob_id"],
              name: "index_active_storage_attachments_uniqueness", unique: true

    add_foreign_key "active_storage_attachments", "active_storage_blobs",
                    column: "blob_id"

    # active_storage_variant_records — tracks image variants per blob
    create_table "active_storage_variant_records" do |t|
      t.bigint "blob_id",          null: false
      t.string "variation_digest", null: false
    end

    add_index "active_storage_variant_records",
              ["blob_id", "variation_digest"],
              name: "index_active_storage_variant_records_uniqueness", unique: true

    add_foreign_key "active_storage_variant_records", "active_storage_blobs",
                    column: "blob_id"
  end
end
