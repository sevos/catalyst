class AddFieldsToCatalystAgents < ActiveRecord::Migration[8.0]
  def change
    add_column :catalyst_agents, :name, :string, null: false
    add_column :catalyst_agents, :model, :string
    add_column :catalyst_agents, :model_params, :text

    change_column_default :catalyst_agents, :max_iterations, from: 1, to: 5
  end
end
