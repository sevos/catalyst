class CreateCatalystAgents < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :catalyst_agents do |t|
      t.string :delegatable_type, null: false
      t.bigint :delegatable_id, null: false
      
      t.integer :max_iterations, default: 1, null: false
      
      t.timestamps
    end
    
    add_index :catalyst_agents, [:delegatable_type, :delegatable_id], unique: true, name: 'index_catalyst_agents_on_delegatable'
  end
end