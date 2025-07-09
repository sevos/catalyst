require "test_helper"

class Catalyst::AgentTest < ActiveSupport::TestCase
  test "creates agent with delegated type" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      max_iterations: 5
    )

    assert_equal application_agent, agent.agentable
    assert_equal "ApplicationAgent", agent.agentable_type
    assert_equal application_agent.id, agent.agentable_id
    assert_equal 5, agent.max_iterations
    assert_equal "Test Agent", agent.name
  end

  test "has default max_iterations of 5" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    assert_equal 5, agent.max_iterations
  end

  test "validates presence of agentable" do
    agent = Catalyst::Agent.new(name: "Test Agent", max_iterations: 3)

    assert_not agent.valid?
    assert_includes agent.errors[:agentable], "must exist"
  end

  test "validates presence of name" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.new(agentable: application_agent, max_iterations: 3)

    assert_not agent.valid?
    assert_includes agent.errors[:name], "can't be blank"
  end

  test "validates max_iterations is positive" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.new(
      name: "Test Agent",
      agentable: application_agent,
      max_iterations: 0
    )

    assert_not agent.valid?
    assert_includes agent.errors[:max_iterations], "must be greater than 0"
  end

  test "has many executions" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      max_iterations: 2
    )

    execution1 = agent.executions.create!(
      status: :pending,
      prompt: "First task"
    )

    execution2 = agent.executions.create!(
      status: :completed,
      prompt: "Second task",
      result: "Task completed successfully"
    )

    assert_equal 2, agent.executions.count
    assert_includes agent.executions, execution1
    assert_includes agent.executions, execution2
  end

  test "supports nested attributes via agent_attributes" do
    application_agent = ApplicationAgent.create!(
      role: "Marketing Assistant",
      goal: "Create marketing content",
      backstory: "Expert in brand marketing",
      agent_attributes: {
        name: "Marketing Agent",
        max_iterations: 10
      }
    )

    assert_not_nil application_agent.catalyst_agent
    assert_equal 10, application_agent.catalyst_agent.max_iterations
    assert_equal application_agent, application_agent.catalyst_agent.agentable
  end

  test "supports nested attributes via catalyst_agent_attributes" do
    application_agent = ApplicationAgent.create!(
      role: "Data Analyst",
      goal: "Analyze business data",
      backstory: "Expert in data science",
      catalyst_agent_attributes: {
        name: "Data Agent",
        max_iterations: 15
      }
    )

    assert_not_nil application_agent.catalyst_agent
    assert_equal 15, application_agent.catalyst_agent.max_iterations
    assert_equal application_agent, application_agent.catalyst_agent.agentable
  end

  test "nested attributes create catalyst_agent with defaults when not specified" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant",
      agent_attributes: { name: "Test Agent" }
    )

    assert_not_nil application_agent.catalyst_agent
    assert_equal 5, application_agent.catalyst_agent.max_iterations
  end

  test "stores and retrieves model information" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model: "gpt-4.1-mini"
    )

    assert_equal "gpt-4.1-mini", agent.model
  end

  test "stores and retrieves model parameters as JSON" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model_params: { "temperature" => 0.1, "max_tokens" => 1000 }.to_json
    )

    params = agent.model_parameters
    assert_equal 0.1, params["temperature"]
    assert_equal 1000, params["max_tokens"]
  end

  test "handles empty model parameters" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    assert_equal({}, agent.model_parameters)
  end

  test "handles invalid JSON in model parameters" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model_params: "invalid json"
    )

    assert_equal({}, agent.model_parameters)
  end

  test "sets model parameters using helper method" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    params = { "temperature" => 0.2, "max_tokens" => 500 }
    agent.model_parameters = params

    assert_equal 0.2, agent.model_parameter("temperature")
    assert_equal 500, agent.model_parameter("max_tokens")
  end

  test "gets and sets individual model parameters" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    agent.set_model_parameter("temperature", 0.3)
    agent.set_model_parameter("top_p", 0.9)

    assert_equal 0.3, agent.model_parameter("temperature")
    assert_equal 0.9, agent.model_parameter("top_p")
  end

  test "handles nil model_parameters assignment" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model_params: { "temperature" => 0.1 }.to_json
    )

    agent.model_parameters = nil
    assert_nil agent.model_params
    assert_equal({}, agent.model_parameters)
  end

  test "handles string model_parameters assignment" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    json_string = '{"temperature": 0.2, "max_tokens": 800}'
    agent.model_parameters = json_string

    assert_equal 0.2, agent.model_parameter("temperature")
    assert_equal 800, agent.model_parameter("max_tokens")
  end
end
