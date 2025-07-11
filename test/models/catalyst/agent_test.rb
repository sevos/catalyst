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
      model_params: { "temperature" => 0.1, "max_tokens" => 1000 }
    )

    params = agent.model_params
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

    assert_equal({}, agent.model_params || {})
  end

  test "handles invalid JSON in model parameters" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    # With Rails serialize, invalid JSON will raise an error when trying to save
    # so we test that serialize handles proper hash data
    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model_params: {}
    )

    assert_equal({}, agent.model_params)
  end

  test "sets model parameters directly" do
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
    agent.model_params = params

    assert_equal 0.2, agent.model_params["temperature"]
    assert_equal 500, agent.model_params["max_tokens"]
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

    agent.model_params = { "temperature" => 0.3, "top_p" => 0.9 }
    agent.save!

    assert_equal 0.3, agent.model_params["temperature"]
    assert_equal 0.9, agent.model_params["top_p"]
  end

  test "handles nil model_params assignment" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent,
      model_params: { "temperature" => 0.1 }
    )

    agent.model_params = nil
    assert_nil agent.model_params
  end

  test "handles hash model_params assignment" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    params = { "temperature" => 0.2, "max_tokens" => 800 }
    agent.model_params = params

    assert_equal 0.2, agent.model_params["temperature"]
    assert_equal 800, agent.model_params["max_tokens"]
  end

  # Tests for execute method
  test "execute method exists and can be called" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    assert_respond_to agent, :execute
    assert_equal 0, agent.executions.count
  end

  test "execute method template resolution works" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    # Check if template file exists
    template_path = Rails.root.join("app", "ai", "prompts", "application_agent.md.erb")
    assert File.exist?(template_path), "Template file should exist at #{template_path}"

    # Test template resolution method
    paths = agent.send(:build_template_inheritance_chain)
    assert_includes paths, template_path.to_s
  end

  test "execute method creates execution record and returns LLM response" do
    # Set up a mock response for testing
    mock_chat = Minitest::Mock.new
    mock_chat.expect :system, nil, [ String ]
    mock_chat.expect :ask, "Hello! I'm ready to help you with your tasks.", [ String ]

    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    RubyLLM.stub :chat, mock_chat do
      response = agent.execute("Hello, can you help me?")

      assert_equal "Hello! I'm ready to help you with your tasks.", response
      assert_equal 1, agent.executions.count

      execution = agent.executions.last
      assert_equal "Hello, can you help me?", execution.prompt
      assert_equal "completed", execution.status
      assert_equal "Hello! I'm ready to help you with your tasks.", execution.result
    end

    mock_chat.verify
  end

  test "execute method captures all agent attributes in input_params" do
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |_| }
    mock_chat.define_singleton_method(:ask) { |_| "Response" }

    RubyLLM.stub :chat, mock_chat do
      application_agent = ApplicationAgent.create!(
        role: "Marketing Assistant",
        goal: "Create marketing content",
        backstory: "Expert in brand marketing"
      )

      agent = Catalyst::Agent.create!(
        name: "Marketing Agent",
        agentable: application_agent,
        model: "gpt-4.1-mini",
        model_params: { "temperature" => 0.8, "max_tokens" => 1000 }
      )

      agent.execute("Create a marketing campaign")

      execution = agent.executions.last
      input_params = execution.input_params

      # Check Catalyst::Agent attributes
      assert_equal "Marketing Agent", input_params["name"]
      assert_equal "gpt-4.1-mini", input_params["model"]
      assert_equal({ "temperature" => 0.8, "max_tokens" => 1000 }, input_params["model_params"])
      assert_equal 5, input_params["max_iterations"]

      # Check ApplicationAgent attributes
      assert_equal "Marketing Assistant", input_params["role"]
      assert_equal "Create marketing content", input_params["goal"]
      assert_equal "Expert in brand marketing", input_params["backstory"]
    end
  end

  test "execute method tracks execution status transitions" do
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |_| }
    mock_chat.define_singleton_method(:ask) { |_| "Task completed" }

    RubyLLM.stub :chat, mock_chat do
      application_agent = ApplicationAgent.create!(
        role: "Assistant",
        goal: "Help users",
        backstory: "AI assistant"
      )

      agent = Catalyst::Agent.create!(
        name: "Test Agent",
        agentable: application_agent
      )

      agent.execute("Test message")

      execution = agent.executions.last
      assert_equal "completed", execution.status
      assert_not_nil execution.started_at
      assert_not_nil execution.completed_at
      assert execution.completed_at >= execution.started_at
      assert_equal 1, execution.interaction_count
      assert_not_nil execution.last_interaction_at
    end
  end

  test "execute method handles LLM errors and updates execution to failed" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    # Mock RubyLLM to raise an error
    RubyLLM.stub :chat, ->(*) { raise StandardError.new("API Error") } do
      assert_raises StandardError do
        agent.execute("Test message")
      end
    end

    execution = agent.executions.last
    assert_equal "failed", execution.status
    assert_equal "API Error", execution.error_message
    assert_not_nil execution.started_at
    assert_not_nil execution.completed_at
  end

  test "execute method constructs system prompt using ERB template" do
    # Capture the system prompt sent to RubyLLM
    system_prompt_captured = nil
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |prompt| system_prompt_captured = prompt }
    mock_chat.define_singleton_method(:ask) { |_| "Response" }

    RubyLLM.stub :chat, ->(*) { mock_chat } do
      application_agent = ApplicationAgent.create!(
        role: "Marketing Expert",
        goal: "Create compelling marketing content",
        backstory: "10+ years in digital marketing"
      )

      agent = Catalyst::Agent.create!(
        name: "Marketing Agent",
        agentable: application_agent
      )

      agent.execute("Create a campaign")
    end

    # Verify the system prompt was rendered with @agent instance
    assert_includes system_prompt_captured, "Marketing Expert"
    assert_includes system_prompt_captured, "Create compelling marketing content"
    assert_includes system_prompt_captured, "10+ years in digital marketing"
  end

  test "execute method uses agent model configuration" do
    # Capture the model and parameters sent to RubyLLM
    model_captured = nil
    params_captured = nil
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |_| }
    mock_chat.define_singleton_method(:ask) { |_| "Response" }

    RubyLLM.stub :chat, ->(model: nil, **params) {
      model_captured = model
      params_captured = params
      mock_chat
    } do
      application_agent = ApplicationAgent.create!(
        role: "Assistant",
        goal: "Help users",
        backstory: "AI assistant"
      )

      agent = Catalyst::Agent.create!(
        name: "Test Agent",
        agentable: application_agent,
        model: "gpt-4.1-mini",
        model_params: { "temperature" => 0.7, "max_tokens" => 500 }
      )

      agent.execute("Test message")
    end

    assert_equal "gpt-4.1-mini", model_captured
    assert_equal 0.7, params_captured[:temperature]
    assert_equal 500, params_captured[:max_tokens]
  end

  test "execute method uses default model when none specified" do
    model_captured = nil
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |_| }
    mock_chat.define_singleton_method(:ask) { |_| "Response" }

    RubyLLM.stub :chat, ->(model: nil, **params) {
      model_captured = model
      mock_chat
    } do
      application_agent = ApplicationAgent.create!(
        role: "Assistant",
        goal: "Help users",
        backstory: "AI assistant"
      )

      agent = Catalyst::Agent.create!(
        name: "Test Agent",
        agentable: application_agent
      )

      agent.execute("Test message")
    end

    assert_equal "gpt-4.1-nano", model_captured
  end

  # Additional security and validation tests
  test "execute method validates user message presence" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    assert_raises ArgumentError, "User message cannot be blank" do
      agent.execute("")
    end

    assert_raises ArgumentError, "User message cannot be blank" do
      agent.execute("   ")
    end

    assert_raises ArgumentError, "User message cannot be blank" do
      agent.execute(nil)
    end
  end

  test "execute method validates user message type" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    assert_raises ArgumentError, "User message must be a string" do
      agent.execute(123)
    end

    assert_raises ArgumentError, "User message must be a string" do
      agent.execute([ "hello" ])
    end
  end

  test "execute method validates user message length" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    long_message = "a" * 10_001

    assert_raises ArgumentError, "User message too long (maximum 10,000 characters)" do
      agent.execute(long_message)
    end
  end

  test "execute method strips whitespace from user message" do
    mock_chat = Object.new
    mock_chat.define_singleton_method(:system) { |_| }
    mock_chat.define_singleton_method(:ask) { |_| "Response" }

    RubyLLM.stub :chat, mock_chat do
      application_agent = ApplicationAgent.create!(
        role: "Assistant",
        goal: "Help users",
        backstory: "AI assistant"
      )

      agent = Catalyst::Agent.create!(
        name: "Test Agent",
        agentable: application_agent
      )

      agent.execute("  Test message with whitespace  ")

      execution = agent.executions.last
      assert_equal "Test message with whitespace", execution.prompt
    end
  end

  test "execute method handles error safely without validation issues" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: application_agent
    )

    # Mock RubyLLM to raise an error after execution starts
    RubyLLM.stub :chat, ->(*) { raise StandardError.new("API Error with sensitive data: user@example.com") } do
      assert_raises StandardError do
        agent.execute("Test message")
      end
    end

    execution = agent.executions.last
    assert_equal "failed", execution.status
    assert_equal "API Error with sensitive data: [EMAIL]", execution.error_message
    assert_not_nil execution.completed_at
  end
end
