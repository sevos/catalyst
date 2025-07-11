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
      assert_match(/t\.string :agentable_type, null: false/, migration)
      assert_match(/t\.bigint :agentable_id, null: false/, migration)
      assert_match(/t\.string :name, null: false/, migration)
      assert_match(/t\.string :model/, migration)
      assert_match(/t\.text :model_params/, migration)
      assert_match(/t\.integer :max_iterations, default: 5, null: false/, migration)
      assert_match(/add_index :catalyst_agents, \[:agentable_type, :agentable_id\]/, migration)
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
      assert_match(/t\.text :error_message/, migration)
      assert_match(/t\.datetime :started_at/, migration)
      assert_match(/t\.datetime :completed_at/, migration)
      assert_match(/t\.json :metadata/, migration)
      assert_match(/t\.integer :interaction_count, default: 0, null: false/, migration)
      assert_match(/t\.datetime :last_interaction_at/, migration)
      assert_match(/t\.text :input_params/, migration)
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
      assert_match(/include Catalyst::Agentable/, model)
      assert_match(/# This model is your default, simple agent type/, model)
      assert_match(/# It has the role, goal, and backstory attributes/, model)
      assert_match(/# You can add shared logic for all "generic" agents here/, model)
    end
  end

  test "creates ai directory" do
    run_generator

    assert_directory "app/ai"
  end

  test "creates prompts directory" do
    run_generator

    assert_directory "app/ai/prompts"
  end

  test "generates ApplicationAgent prompt file" do
    run_generator

    assert_file "app/ai/prompts/application_agent.md.erb" do |content|
      assert_match(/# System Instructions/, content)
      assert_match(/## Your Role/, content)
      assert_match(/<%= @agent\.role %>/, content)
      assert_match(/## Your Primary Goal/, content)
      assert_match(/<%= @agent\.goal %>/, content)
      assert_match(/## Your Background & Context/, content)
      assert_match(/<%= @agent\.backstory %>/, content)
      assert_match(/## Instructions/, content)
      assert_match(/Always stay in character/, content)
    end
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

  test "existing install functionality unchanged" do
    run_generator

    # Test all existing assertions still pass
    assert_migration "db/migrate/create_catalyst_agents.rb"
    assert_migration "db/migrate/create_application_agents.rb"
    assert_migration "db/migrate/create_catalyst_executions.rb"
    assert_file "config/initializers/catalyst.rb"
    assert_file "app/ai/application_agent.rb"
    assert_directory "app/ai"
  end

  test "gemspec includes ruby_llm dependency" do
    # Read the gemspec file
    gemspec_path = File.expand_path("../../../catalyst.gemspec", __dir__)
    gemspec_content = File.read(gemspec_path)

    # Assert ruby_llm dependency is present
    assert_match(/spec\.add_dependency "ruby_llm", "~> 1\.3"/, gemspec_content)
  end

  test "generates ruby_llm initializer" do
    run_generator

    assert_file "config/initializers/ruby_llm.rb" do |initializer|
      assert_match(/RubyLLM\.configure do \|config\|/, initializer)
      assert_match(/config\.openai_api_key = ENV\.fetch\('OPENAI_API_KEY', nil\) \|\|/, initializer)
      assert_match(/Rails\.application\.credentials\.dig\(:catalyst, :openai_api_key\)/, initializer)
      assert_match(/config\.default_model = 'gpt-4\.1-nano'/, initializer)
      assert_match(/config\.default_embedding_model = 'text-embedding-3-small'/, initializer)
      assert_match(/config\.request_timeout = 120/, initializer)
      assert_match(/config\.max_retries = 3/, initializer)
      assert_match(/config\.anthropic_api_key = ENV\.fetch\('ANTHROPIC_API_KEY', nil\) \|\|/, initializer)
      assert_match(/config\.gemini_api_key = ENV\.fetch\('GEMINI_API_KEY', nil\) \|\|/, initializer)
      assert_match(/config\.log_file = Rails\.root\.join\('log\/ruby_llm\.log'\)/, initializer)
      assert_match(/config\.log_level = Rails\.env\.development\? \? :debug : :info/, initializer)
    end
  end

  test "does not overwrite existing ruby_llm initializer" do
    create_file "config/initializers/ruby_llm.rb", "# existing ruby_llm content"

    run_generator

    assert_file "config/initializers/ruby_llm.rb", "# existing ruby_llm content"
  end


  private

  def create_file(file_path, content)
    full_path = destination_root.join(file_path)
    FileUtils.mkdir_p(full_path.dirname)
    File.write(full_path, content)
  end
end
