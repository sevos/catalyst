require "test_helper"
require "generators/catalyst/install/install_generator"

class Catalyst::InstallGeneratorTest < Rails::Generators::TestCase
  tests Catalyst::InstallGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generates migration files" do
    run_generator

    assert_migration "db/migrate/create_catalyst_agents.rb" do |migration|
      assert_match(/create_table :catalyst_agents/, migration)
      assert_match(/t\.string :delegatable_type, null: false/, migration)
      assert_match(/t\.bigint :delegatable_id, null: false/, migration)
      assert_match(/t\.integer :max_iterations, default: 1, null: false/, migration)
      assert_match(/add_index :catalyst_agents, \[:delegatable_type, :delegatable_id\]/, migration)
    end

    assert_migration "db/migrate/create_application_agents.rb" do |migration|
      assert_match(/create_table :application_agents/, migration)
      assert_match(/t\.string :role/, migration)
      assert_match(/t\.text :goal/, migration)
      assert_match(/t\.text :backstory/, migration)
    end

    assert_migration "db/migrate/create_catalyst_executions.rb" do |migration|
      assert_match(/create_table :catalyst_executions/, migration)
      assert_match(/t\.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }/, migration)
      assert_match(/t\.string :status, null: false/, migration)
      assert_match(/t\.text :prompt, null: false/, migration)
      assert_match(/t\.text :result/, migration)
      assert_match(/t\.json :metadata/, migration)
    end
  end

  test "generates initializer file" do
    run_generator

    assert_file "config/initializers/catalyst.rb" do |initializer|
      assert_match(/Catalyst\.configure do \|config\|/, initializer)
      assert_match(/config\.register_agent_type "ApplicationAgent"/, initializer)
      assert_match(/# config\.register_agent_type "MarketingAgent"/, initializer)
    end
  end

  test "generates ApplicationAgent model" do
    run_generator

    assert_file "app/ai/application_agent.rb" do |model|
      assert_match(/class ApplicationAgent < ApplicationRecord/, model)
      assert_match(/# This model is your default, simple agent type/, model)
      assert_match(/# It has the role, goal, and backstory attributes/, model)
      assert_match(/# You can add shared logic for all "generic" agents here/, model)
    end
  end

  test "creates ai directory" do
    run_generator

    assert_directory "app/ai"
  end

  test "generates files in correct order" do
    run_generator

    migration_files = Dir[destination_root.join("db/migrate/*.rb")]
    assert_equal 3, migration_files.length

    catalyst_agents_migration = migration_files.find { |f| f.include?("create_catalyst_agents") }
    application_agents_migration = migration_files.find { |f| f.include?("create_application_agents") }
    executions_migration = migration_files.find { |f| f.include?("create_catalyst_executions") }

    assert catalyst_agents_migration
    assert application_agents_migration
    assert executions_migration
  end

  test "does not overwrite existing files" do
    create_file "config/initializers/catalyst.rb", "# existing content"
    
    run_generator

    assert_file "config/initializers/catalyst.rb", "# existing content"
  end


  private

  def create_file(file_path, content)
    full_path = destination_root.join(file_path)
    FileUtils.mkdir_p(full_path.dirname)
    File.write(full_path, content)
  end
end