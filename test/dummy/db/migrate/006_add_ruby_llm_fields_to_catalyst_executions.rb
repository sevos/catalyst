class AddRubyLlmFieldsToCatalystExecutions < ActiveRecord::Migration[8.0]
  def change
    add_column :catalyst_executions, :interaction_count, :integer, default: 0, null: false
    add_column :catalyst_executions, :last_interaction_at, :datetime
    add_column :catalyst_executions, :input_params, :text
  end
end
