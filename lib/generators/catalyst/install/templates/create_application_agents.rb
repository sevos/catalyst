class CreateApplicationAgents < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :application_agents do |t|
      t.string :role
      t.text :goal
      t.text :backstory
      
      t.timestamps
    end
  end
end