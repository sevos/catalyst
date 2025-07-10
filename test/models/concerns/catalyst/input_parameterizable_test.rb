require "test_helper"

class Catalyst::InputParameterizableTest < ActiveSupport::TestCase
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

    @execution = Catalyst::Execution.create!(
      agent: @agent,
      status: "pending",
      prompt: "Test task"
    )
  end

  test "input_parameters returns empty hash when input_params is nil" do
    assert_equal({}, @execution.input_parameters)
  end

  test "input_parameters stores and retrieves parameters" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    @execution.input_params = params

    assert_equal params, @execution.input_parameters
    assert_equal params, @execution.input_params
  end

  test "input_parameters= sets parameters correctly" do
    params = { "model" => "gpt-4.1-nano", "temperature" => 0.8 }
    @execution.input_parameters = params

    assert_equal params, @execution.input_parameters
  end

  test "input_parameter returns specific parameter value" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    @execution.input_params = params

    assert_equal 0.7, @execution.input_parameter("temperature")
    assert_equal 150, @execution.input_parameter("max_tokens")
    assert_nil @execution.input_parameter("nonexistent")
  end

  test "input_parameter accepts symbol keys" do
    params = { "temperature" => 0.7 }
    @execution.input_params = params

    assert_equal 0.7, @execution.input_parameter(:temperature)
  end

  test "set_input_parameter adds new parameter" do
    @execution.set_input_parameter("temperature", 0.9)

    assert_equal 0.9, @execution.input_parameter("temperature")
    assert_equal({ "temperature" => 0.9 }, @execution.input_parameters)
  end

  test "set_input_parameter updates existing parameter" do
    params = { "temperature" => 0.7, "max_tokens" => 150 }
    @execution.input_params = params

    @execution.set_input_parameter("temperature", 0.9)

    assert_equal 0.9, @execution.input_parameter("temperature")
    assert_equal 150, @execution.input_parameter("max_tokens")
  end

  test "set_input_parameter accepts symbol keys" do
    @execution.set_input_parameter(:temperature, 0.9)

    assert_equal 0.9, @execution.input_parameter("temperature")
  end

  test "input_params serialization works with JSON" do
    params = { "temperature" => 0.7, "max_tokens" => 150, "nested" => { "key" => "value" } }
    @execution.input_parameters = params
    @execution.save!
    @execution.reload

    assert_equal params, @execution.input_parameters
    assert_equal "value", @execution.input_parameter("nested")["key"]
  end

  test "input_parameters= transforms symbol keys to strings" do
    params = { temperature: 0.7, max_tokens: 150 }
    @execution.input_parameters = params

    assert_equal({ "temperature" => 0.7, "max_tokens" => 150 }, @execution.input_parameters)
  end

  test "input_parameters= handles nil gracefully" do
    @execution.input_parameters = nil

    assert_equal({}, @execution.input_parameters)
  end

  test "merge_input_parameters adds new parameters" do
    @execution.input_parameters = { "temperature" => 0.7 }
    
    @execution.merge_input_parameters({ "max_tokens" => 150, "model" => "gpt-4.1-nano" })

    expected = { "temperature" => 0.7, "max_tokens" => 150, "model" => "gpt-4.1-nano" }
    assert_equal expected, @execution.input_parameters
  end

  test "merge_input_parameters overwrites existing parameters" do
    @execution.input_parameters = { "temperature" => 0.7, "max_tokens" => 100 }
    
    @execution.merge_input_parameters({ "temperature" => 0.9, "model" => "gpt-4.1-nano" })

    expected = { "temperature" => 0.9, "max_tokens" => 100, "model" => "gpt-4.1-nano" }
    assert_equal expected, @execution.input_parameters
  end

  test "merge_input_parameters transforms symbol keys" do
    @execution.input_parameters = { "temperature" => 0.7 }
    
    @execution.merge_input_parameters({ max_tokens: 150, model: "gpt-4.1-nano" })

    expected = { "temperature" => 0.7, "max_tokens" => 150, "model" => "gpt-4.1-nano" }
    assert_equal expected, @execution.input_parameters
  end

  test "merge_input_parameters handles nil gracefully" do
    @execution.input_parameters = { "temperature" => 0.7 }
    
    @execution.merge_input_parameters(nil)

    assert_equal({ "temperature" => 0.7 }, @execution.input_parameters)
  end

  test "remove_input_parameter removes existing parameter" do
    @execution.input_parameters = { "temperature" => 0.7, "max_tokens" => 150 }
    
    @execution.remove_input_parameter("temperature")

    assert_equal({ "max_tokens" => 150 }, @execution.input_parameters)
  end

  test "remove_input_parameter accepts symbol keys" do
    @execution.input_parameters = { "temperature" => 0.7, "max_tokens" => 150 }
    
    @execution.remove_input_parameter(:temperature)

    assert_equal({ "max_tokens" => 150 }, @execution.input_parameters)
  end

  test "remove_input_parameter handles non-existent key gracefully" do
    @execution.input_parameters = { "temperature" => 0.7 }
    
    @execution.remove_input_parameter("nonexistent")

    assert_equal({ "temperature" => 0.7 }, @execution.input_parameters)
  end

  test "clear_input_parameters removes all parameters" do
    @execution.input_parameters = { "temperature" => 0.7, "max_tokens" => 150 }
    
    @execution.clear_input_parameters

    assert_equal({}, @execution.input_parameters)
  end
end