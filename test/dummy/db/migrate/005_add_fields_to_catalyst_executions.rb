class AddFieldsToCatalystExecutions < ActiveRecord::Migration[8.0]
  def change
    add_column :catalyst_executions, :error_message, :text
    add_column :catalyst_executions, :started_at, :datetime
    add_column :catalyst_executions, :completed_at, :datetime
  end
end
