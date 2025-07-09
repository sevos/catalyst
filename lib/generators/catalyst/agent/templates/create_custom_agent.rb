class Create<%= class_name.pluralize %> < ActiveRecord::Migration[<%= Rails::VERSION::MAJOR %>.<%= Rails::VERSION::MINOR %>]
  def change
    create_table :<%= table_name %> do |t|
<%= migration_columns %>
      t.string :role
      t.text :goal
      t.text :backstory
      t.json :agent_attributes, default: {}

      t.timestamps
    end
  end
end