require "test_helper"

class Catalyst::ExecutionTest < ActiveSupport::TestCase
  setup do
    @application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    @agent = Catalyst::Agent.create!(
      name: "Test Agent",
      agentable: @application_agent,
      max_iterations: 3
    )
  end

  test "creates execution with required attributes" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :pending,
      prompt: "Complete this task"
    )

    assert_equal @agent, execution.agent
    assert_equal "pending", execution.status
    assert_equal "Complete this task", execution.prompt
    assert_nil execution.result
  end

  test "creates execution with result" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :completed,
      prompt: "Calculate 2 + 2",
      result: "The answer is 4"
    )

    assert_equal @agent, execution.agent
    assert_equal "completed", execution.status
    assert_equal "Calculate 2 + 2", execution.prompt
    assert_equal "The answer is 4", execution.result
  end

  test "validates presence of agent" do
    execution = Catalyst::Execution.new(
      status: :pending,
      prompt: "Test task"
    )

    assert_not execution.valid?
    assert_includes execution.errors[:agent], "must exist"
  end

  test "has default status of pending" do
    execution = Catalyst::Execution.new(
      agent: @agent,
      prompt: "Test task"
    )

    assert_equal "pending", execution.status
    assert execution.pending?
  end

  test "validates presence of prompt" do
    execution = Catalyst::Execution.new(
      agent: @agent,
      status: "pending"
    )

    assert_not execution.valid?
    assert_includes execution.errors[:prompt], "can't be blank"
  end

  test "validates status is in allowed values" do
    valid_statuses = [ :pending, :running, :completed, :failed ]

    valid_statuses.each do |status|
      execution = Catalyst::Execution.new(
        agent: @agent,
        status: status,
        prompt: "Test task"
      )
      assert execution.valid?, "Status '#{status}' should be valid"
    end

    execution = Catalyst::Execution.new(
      agent: @agent,
      prompt: "Test task"
    )

    assert_raises(ArgumentError) do
      execution.status = "invalid_status"
    end
  end


  test "belongs to agent" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :pending,
      prompt: "Test task"
    )

    assert_equal @agent, execution.agent
    assert_equal @agent.id, execution.agent_id
  end

  test "can store execution metadata" do
    metadata = {
      "iterations_used" => 2,
      "tokens_consumed" => 150,
      "model_used" => "gpt-4"
    }

    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :completed,
      prompt: "Test task",
      result: "Task completed",
      metadata: metadata
    )

    assert_equal metadata, execution.metadata
    assert_equal 2, execution.metadata["iterations_used"]
    assert_equal 150, execution.metadata["tokens_consumed"]
    assert_equal "gpt-4", execution.metadata["model_used"]
  end

  test "start! method updates status and started_at timestamp" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :pending,
      prompt: "Test task"
    )

    assert_nil execution.started_at
    assert execution.pending?

    execution.start!

    assert_not_nil execution.started_at
    assert execution.running?
    assert_equal "running", execution.status
  end

  test "complete! method updates status, completed_at timestamp, and result" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :running,
      prompt: "Test task",
      started_at: 1.hour.ago
    )

    assert_nil execution.completed_at
    assert execution.running?

    execution.complete!("Task completed successfully")

    assert_not_nil execution.completed_at
    assert execution.completed?
    assert_equal "completed", execution.status
    assert_equal "Task completed successfully", execution.result
  end

  test "fail! method updates status, completed_at timestamp, and error_message" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :running,
      prompt: "Test task",
      started_at: 1.hour.ago
    )

    assert_nil execution.completed_at
    assert_nil execution.error_message
    assert execution.running?

    execution.fail!("Something went wrong")

    assert_not_nil execution.completed_at
    assert execution.failed?
    assert_equal "failed", execution.status
    assert_equal "Something went wrong", execution.error_message
  end

  test "running? method returns true when status is running" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :running,
      prompt: "Test task"
    )

    assert execution.running?
    assert_not execution.pending?
    assert_not execution.completed?
    assert_not execution.failed?
  end

  test "finished? method returns true when execution is completed or failed" do
    completed_execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :completed,
      prompt: "Test task"
    )

    failed_execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :failed,
      prompt: "Test task"
    )

    running_execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :running,
      prompt: "Test task"
    )

    assert completed_execution.finished?
    assert failed_execution.finished?
    assert_not running_execution.finished?
  end

  test "duration method calculates execution time" do
    start_time = 1.hour.ago
    end_time = 30.minutes.ago

    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :completed,
      prompt: "Test task",
      started_at: start_time,
      completed_at: end_time
    )

    expected_duration = end_time - start_time
    assert_in_delta expected_duration, execution.duration, 0.001
  end

  test "duration method returns nil when timestamps are missing" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :pending,
      prompt: "Test task"
    )

    assert_nil execution.duration
  end

  test "stores error_message for failed executions" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      status: :failed,
      prompt: "Test task",
      error_message: "Timeout occurred"
    )

    assert_equal "Timeout occurred", execution.error_message
  end

  test "validates timestamps consistency" do
    execution = Catalyst::Execution.new(
      agent: @agent,
      status: :completed,
      prompt: "Test task",
      started_at: 1.hour.ago,
      completed_at: 2.hours.ago  # This should fail validation
    )

    assert_not execution.valid?
    assert_includes execution.errors[:completed_at], "must be after started_at"
  end

  # Tests for new chat-like fields and parameter management
  test "creates execution with default interaction_count of 0" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task"
    )

    assert_equal 0, execution.interaction_count
    assert_nil execution.last_interaction_at
  end

  test "validates interaction_count is non-negative" do
    execution = Catalyst::Execution.new(
      agent: @agent,
      prompt: "Test task",
      interaction_count: -1
    )

    assert_not execution.valid?
    assert_includes execution.errors[:interaction_count], "must be greater than or equal to 0"
  end

  test "input_params returns empty hash when nil" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task"
    )

    assert_equal({}, execution.input_params || {})
  end

  test "input_params stores and retrieves parameters" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      input_params: params
    )

    assert_equal params, execution.input_params
  end

  test "input_params= sets parameters correctly" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task"
    )

    params = { "model" => "gpt-4.1-nano", "temperature" => 0.8 }
    execution.input_params = params

    assert_equal params, execution.input_params
  end

  test "input_params allows access to specific parameter values" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      input_params: params
    )

    assert_equal 0.7, execution.input_params["temperature"]
    assert_equal 150, execution.input_params["max_tokens"]
    assert_nil execution.input_params["nonexistent"]
  end

  test "input_params works with string keys" do
    params = { "temperature" => 0.7 }
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      input_params: params
    )

    assert_equal 0.7, execution.input_params["temperature"]
  end

  test "input_params can be updated with new parameters" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task"
    )

    execution.input_params = { "temperature" => 0.9 }
    execution.save!

    assert_equal 0.9, execution.input_params["temperature"]
    assert_equal({ "temperature" => 0.9 }, execution.input_params)
  end

  test "input_params can be updated with existing parameters" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      input_params: params
    )

    execution.input_params = execution.input_params.merge("temperature" => 0.9)
    execution.save!

    assert_equal 0.9, execution.input_params["temperature"]
    assert_equal 150, execution.input_params["max_tokens"]
  end

  test "input_params works with hash assignment" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task"
    )

    execution.input_params = { "temperature" => 0.9 }
    execution.save!

    assert_equal 0.9, execution.input_params["temperature"]
  end

  test "increment_interaction! increases count and updates timestamp" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      interaction_count: 0
    )

    assert_nil execution.last_interaction_at

    execution.increment_interaction!

    assert_equal 1, execution.interaction_count
    assert_not_nil execution.last_interaction_at
    assert_in_delta Time.current, execution.last_interaction_at, 1.second
  end

  test "increment_interaction! works with zero interaction_count" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      interaction_count: 0
    )

    execution.increment_interaction!

    assert_equal 1, execution.interaction_count
    assert_not_nil execution.last_interaction_at
  end

  test "increment_interaction! persists changes to database" do
    execution = Catalyst::Execution.create!(
      agent: @agent,
      prompt: "Test task",
      interaction_count: 2
    )

    execution.increment_interaction!

    execution.reload
    assert_equal 3, execution.interaction_count
    assert_not_nil execution.last_interaction_at
  end
end
