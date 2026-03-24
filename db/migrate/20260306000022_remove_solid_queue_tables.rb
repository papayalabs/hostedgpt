class RemoveSolidQueueTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :solid_queue_processes, if_exists: true
    drop_table :solid_queue_pauses, if_exists: true
    drop_table :solid_queue_failed_executions, if_exists: true
    drop_table :solid_queue_claimed_executions, if_exists: true
    drop_table :solid_queue_blocked_executions, if_exists: true
    drop_table :solid_queue_jobs, if_exists: true
  end

  def down
    # Recreating SolidQueue tables on rollback would be complex.
    # This migration is intended to be permanent when switching to Sidekiq.
    raise ActiveRecord::IrreversibleMigration, "Cannot rollback removal of SolidQueue tables"
  end
end
