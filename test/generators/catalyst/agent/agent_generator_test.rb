require "test_helper"
require "generators/catalyst/agent/agent_generator"

class Catalyst::AgentGeneratorTest < Rails::Generators::TestCase
  tests Catalyst::AgentGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "generator creates simple agent class" do
    run_generator %w[MyAgent]

    assert_file "app/ai/my_agent.rb" do |content|
      assert_match /class MyAgent < ApplicationAgent/, content
      assert_match /# This agent inherits role, goal, and backstory from ApplicationAgent/, content
    end
  end

  test "generator creates prompt template for simple agent with ERB interpolation" do
    run_generator %w[MyAgent]

    assert_file "app/ai/prompts/my_agent.md.erb" do |content|
      assert_match /# MyAgent Prompt/, content
      assert_match /## Role/, content
      assert_match /<%= role %>/, content
      assert_match /## Goal/, content
      assert_match /<%= goal %>/, content
      assert_match /## Backstory/, content
      assert_match /<%= backstory %>/, content
    end
  end

  test "generator creates prompt template for custom agent with placeholders" do
    run_generator %w[MarketingAgent --custom-attributes campaign_type:string]

    assert_file "app/ai/prompts/marketing_agent.md.erb" do |content|
      assert_match /# MarketingAgent Prompt/, content
      assert_match /\[Define the role for this marketing agent\]/, content
      assert_match /\[Define the goal for this marketing agent\]/, content
      assert_match /\[Define the backstory for this marketing agent\]/, content
      assert_match /## Custom Attributes/, content
      assert_match /Campaign type.*<%= campaign_type %>/, content
    end
  end

  test "generator creates custom agent with attributes" do
    run_generator %w[MarketingAgent --custom-attributes campaign_type:string product_id:integer]

    assert_file "app/models/marketing_agent.rb" do |content|
      assert_match /class MarketingAgent < ApplicationRecord/, content
      assert_match /include Catalyst::Agentable/, content
      assert_match /validates :campaign_type, presence: true/, content
      assert_match /validates :product_id, presence: true/, content
    end
  end

  test "generator creates migration for custom agent" do
    run_generator %w[MarketingAgent --custom-attributes campaign_type:string product_id:integer]

    assert_migration "db/migrate/create_marketing_agents.rb" do |content|
      assert_match /t\.string :campaign_type/, content
      assert_match /t\.integer :product_id/, content
      assert_match /t\.string :role/, content
      assert_match /t\.text :goal/, content
      assert_match /t\.text :backstory/, content
      assert_match /t\.json :agent_attributes/, content
    end
  end

  test "generator updates catalyst initializer for custom agent" do
    # Create a mock initializer file
    initializer_path = File.join(destination_root, "config/initializers/catalyst.rb")
    FileUtils.mkdir_p(File.dirname(initializer_path))
    File.write(initializer_path, <<~RUBY)
      Catalyst.configure do |config|
        # Register all agent types here.
        # The ApplicationAgent is registered by default.
        config.register_agent_type "ApplicationAgent"

        # Example for a custom agent:
        # config.register_agent_type "MarketingAgent"
      end
    RUBY

    run_generator %w[MarketingAgent --custom-attributes campaign_type:string]

    assert_file "config/initializers/catalyst.rb" do |content|
      assert_match /config\.register_agent_type "MarketingAgent"/, content
    end
  end

  test "generator handles multiple custom attributes" do
    run_generator %w[SalesAgent --custom-attributes territory:string quota:decimal start_date:date active:boolean]

    assert_file "app/models/sales_agent.rb" do |content|
      assert_match /validates :territory, presence: true/, content
      assert_match /validates :quota, presence: true/, content
      assert_match /validates :start_date, presence: true/, content
      assert_match /validates :active, presence: true/, content
    end

    assert_migration "db/migrate/create_sales_agents.rb" do |content|
      assert_match /t\.string :territory/, content
      assert_match /t\.decimal :quota/, content
      assert_match /t\.date :start_date/, content
      assert_match /t\.boolean :active/, content
    end
  end

  test "generator follows rails naming conventions" do
    run_generator %w[complex_marketing_agent]

    assert_file "app/ai/complex_marketing_agent.rb" do |content|
      assert_match /class ComplexMarketingAgent < ApplicationAgent/, content
    end

    assert_file "app/ai/prompts/complex_marketing_agent.md.erb" do |content|
      assert_match /# ComplexMarketingAgent Prompt/, content
    end
  end

  test "generator validates attribute names" do
    assert_raises ArgumentError do
      run_generator %w[TestAgent --custom-attributes 123invalid:string]
    end

    assert_raises ArgumentError do
      run_generator %w[TestAgent --custom-attributes invalid-name:string]
    end
  end

  test "generator normalizes column types" do
    run_generator %w[TestAgent --custom-attributes name:str count:int active:bool]

    assert_migration "db/migrate/create_test_agents.rb" do |content|
      assert_match /t\.string :name/, content
      assert_match /t\.integer :count/, content
      assert_match /t\.boolean :active/, content
    end
  end

  test "generator validates column types" do
    assert_raises ArgumentError do
      run_generator %w[TestAgent --custom-attributes invalid:invalid_type]
    end
  end
end
