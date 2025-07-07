class CreateCatalystExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :catalyst_executions do |t|
      t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }
      t.string :status, null: false
      t.text :prompt, null: false
      t.text :result
      t.json :metadata
      
      t.timestamps
    end
  end
end