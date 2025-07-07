class CreateApplicationAgents < ActiveRecord::Migration[8.0]
  def change
    create_table :application_agents do |t|
      t.string :role
      t.text :goal
      t.text :backstory
      
      t.timestamps
    end
  end
end