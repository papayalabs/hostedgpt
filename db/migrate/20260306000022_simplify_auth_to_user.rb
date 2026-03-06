class SimplifyAuthToUser < ActiveRecord::Migration[8.0]
  def up
    # Add email and password_digest directly to users
    add_column :users, :email, :string
    add_column :users, :password_digest, :string
    add_index :users, :email, unique: true

    # Migrate email from people to users (for existing data)
    execute <<-SQL
      UPDATE users u
      SET email = p.email
      FROM people p
      WHERE p.personable_type = 'User' AND p.personable_id = u.id
    SQL

    # Add user_id and deleted_at to clients
    add_column :clients, :user_id, :bigint
    add_column :clients, :deleted_at, :datetime
    add_index :clients, :user_id
    add_foreign_key :clients, :users

    # Migrate person_id to user_id on clients (for existing data)
    execute <<-SQL
      UPDATE clients c
      SET user_id = p.personable_id
      FROM people p
      WHERE p.id = c.person_id AND p.personable_type = 'User'
    SQL

    # Remove old person_id from clients
    remove_foreign_key :clients, :people
    remove_column :clients, :person_id

    # Drop tables in reverse dependency order
    drop_table :authentications
    drop_table :credentials
    drop_table :tombstones
    drop_table :people
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
