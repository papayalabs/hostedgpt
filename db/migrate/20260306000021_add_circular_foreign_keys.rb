# Resolves circular foreign key dependencies that could not be added during
# initial table creation:
#
#   users            → messages  (last_cancelled_message_id)
#   conversations    → messages  (last_assistant_message_id)
#   messages         → documents (content_document_id)
#   documents        → messages  (message_id)
class AddCircularForeignKeys < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key "users", "messages",
                    column: "last_cancelled_message_id"

    add_foreign_key "conversations", "messages",
                    column: "last_assistant_message_id"

    add_foreign_key "messages", "documents",
                    column: "content_document_id"

    add_foreign_key "documents", "messages"
  end
end
