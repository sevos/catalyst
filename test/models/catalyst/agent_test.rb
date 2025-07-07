require "test_helper"

class Catalyst::AgentTest < ActiveSupport::TestCase
  test "creates agent with delegated type" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users with tasks",
      backstory: "I am a helpful AI assistant"
    )

    agent = Catalyst::Agent.create!(
      delegatable: application_agent,
      max_iterations: 5
    )

    assert_equal application_agent, agent.delegatable
    assert_equal "ApplicationAgent", agent.delegatable_type
    assert_equal application_agent.id, agent.delegatable_id
    assert_equal 5, agent.max_iterations
  end

  test "has default max_iterations of 1" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.create!(delegatable: application_agent)

    assert_equal 1, agent.max_iterations
  end

  test "validates presence of delegatable" do
    agent = Catalyst::Agent.new(max_iterations: 3)

    assert_not agent.valid?
    assert_includes agent.errors[:delegatable], "must exist"
  end

  test "validates max_iterations is positive" do
    application_agent = ApplicationAgent.create!(
      role: "Assistant",
      goal: "Help users",
      backstory: "AI assistant"
    )

    agent = Catalyst::Agent.new(
      delegatable: application_agent,
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
      delegatable: application_agent,
      max_iterations: 2
    )

    execution1 = agent.executions.create!(
      status: "pending",
      prompt: "First task"
    )

    execution2 = agent.executions.create!(
      status: "completed",
      prompt: "Second task",
      result: "Task completed successfully"
    )

    assert_equal 2, agent.executions.count
    assert_includes agent.executions, execution1
    assert_includes agent.executions, execution2
  end

end