require "test_helper"

class Catalyst::ExecutionTest < ActiveSupport::TestCase
  setup do
    @application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    @agent = Catalyst::Agent.create!(
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
end
