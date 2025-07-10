class CreateCatalystExecutions < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :catalyst_executions do |t|
      t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }
      t.string :status, null: false
      t.text :prompt, null: false
      t.text :result
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.json :metadata
      
      # Chat-like fields for tracking interactions
      t.integer :interaction_count, default: 0, null: false
      t.datetime :last_interaction_at
      
      # Input parameters field (SQLite compatible with JSON serialization)
      t.text :input_params
      
      t.timestamps
    end
  end
end