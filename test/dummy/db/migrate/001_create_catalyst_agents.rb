class CreateCatalystAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :catalyst_agents do |t|
      t.string :agentable_type, null: false
      t.bigint :agentable_id, null: false

      t.integer :max_iterations, default: 1, null: false

      t.timestamps
    end

    add_index :catalyst_agents, [ :agentable_type, :agentable_id ], unique: true, name: "index_catalyst_agents_on_agentable"
  end
end
