# Execution Flow Architecture

## Overview

The Catalyst Framework's execution flow is designed around **asynchronous processing** using Rails' ActiveJob system. This ensures the host application remains responsive while agents perform complex, time-consuming tasks.

## Execution Phases

### 1. Agent Invocation
```ruby
# From host application
agent = MyAgent.create(
  application_agent_attributes: {
    role: "Marketing Assistant",
    goal: "Create compelling marketing content",
    backstory: "Expert in brand marketing"
  },
  agent_attributes: {
    name: "Marketing Agent",
    model: "gpt-4.1-nano",
    model_params: { "temperature" => 0.7 }
  }
)

# Trigger execution
execution = agent.execute(
  prompt: "Create a marketing campaign for our new product",
  context: { product_id: 123, user_id: current_user.id }
)
```

### 2. Job Enqueueing
```ruby
# Catalyst::Agent#execute method
def execute(prompt:, context: {})
  execution = executions.create!(
    prompt: prompt,
    status: :pending,
    metadata: { context: context }
  )
  
  # Enqueue background job
  Catalyst::ExecutionJob.perform_later(execution.id)
  
  execution
end
```

### 3. Background Execution
```ruby
# Catalyst::ExecutionJob
class Catalyst::ExecutionJob < ApplicationJob
  queue_as :catalyst_agents
  
  def perform(execution_id)
    execution = Catalyst::Execution.find(execution_id)
    
    # Update status
    execution.update!(status: :running, started_at: Time.current)
    
    # Execute agent logic
    result = execute_agent_logic(execution)
    
    # Update with results
    execution.update!(
      status: :completed,
      result: result,
      completed_at: Time.current
    )
    
  rescue => error
    execution.update!(
      status: :failed,
      error_message: error.message,
      completed_at: Time.current
    )
    raise
  end
  
  private
  
  def execute_agent_logic(execution)
    agent = execution.agent
    
    # 1. Prepare execution parameters
    execution_params = prepare_execution_params(agent, execution)
    
    # 2. Construct the full prompt
    full_prompt = construct_prompt(agent, execution)
    
    # 3. Execute agentic iteration loop
    execute_iteration_loop(agent, full_prompt, execution, execution_params)
  end
  
  def prepare_execution_params(agent, execution)
    params = {
      model: agent.model || RubyLLM.default_model,
      **(agent.model_params || {})
    }
    
    # Store parameters for tracking
    execution.update!(input_params: params)
    
    params
  end
end
```

## Agentic Iteration Loop

### Core Loop Structure
```ruby
def execute_iteration_loop(agent, prompt, execution, execution_params)
  iteration = 0
  max_iterations = agent.max_iterations
  
  current_prompt = prompt
  conversation_history = []
  
  while iteration < max_iterations
    iteration += 1
    
    # 1. Send prompt to LLM
    llm_response = send_to_llm(agent, current_prompt, execution_params)
    conversation_history << { type: :assistant, content: llm_response }
    
    # 2. Track interaction
    execution.increment_interaction!
    
    # 3. Parse for tool calls
    tool_calls = parse_tool_calls(llm_response)
    
    if tool_calls.empty?
      # No tools needed, we're done
      return {
        final_response: llm_response,
        conversation_history: conversation_history,
        iterations_used: iteration,
        interaction_count: execution.interaction_count
      }
    end
    
    # 4. Execute tools
    tool_results = execute_tools(tool_calls, execution)
    
    # 5. Construct next prompt with tool results
    current_prompt = construct_continuation_prompt(
      conversation_history,
      tool_calls,
      tool_results
    )
    
    conversation_history << { type: :tool_results, content: tool_results }
  end
  
  # Max iterations reached
  {
    final_response: "Maximum iterations reached",
    conversation_history: conversation_history,
    iterations_used: iteration,
    interaction_count: execution.interaction_count,
    status: :max_iterations_reached
  }
end
```

## LLM Integration

### Adapter Pattern Implementation
```ruby
# Base adapter interface
class Catalyst::LlmAdapters::Base
  def initialize(config)
    @config = config
  end
  
  def call(prompt:, model:, temperature: 0.7, max_tokens: 1000)
    raise NotImplementedError
  end
end

# OpenAI adapter
class Catalyst::LlmAdapters::OpenaiAdapter < Base
  def call(prompt:, model:, temperature: 0.7, max_tokens: 1000)
    client = OpenAI::Client.new(access_token: @config[:api_key])
    
    response = client.chat(
      parameters: {
        model: model,
        messages: [{ role: "user", content: prompt }],
        temperature: temperature,
        max_tokens: max_tokens
      }
    )
    
    response.dig("choices", 0, "message", "content")
  end
end
```

## Tool Execution System

### Tool Discovery and Execution
```ruby
def execute_tools(tool_calls, execution)
  results = []
  
  tool_calls.each do |tool_call|
    tool_class = resolve_tool_class(tool_call[:name])
    
    if tool_class.nil?
      results << {
        tool: tool_call[:name],
        success: false,
        error: "Tool not found: #{tool_call[:name]}"
      }
      next
    end
    
    begin
      # Execute tool with context
      tool_instance = tool_class.new(
        execution_context: execution.metadata["context"]
      )
      
      result = tool_instance.call(tool_call[:arguments])
      
      results << {
        tool: tool_call[:name],
        success: true,
        result: result
      }
      
    rescue => error
      results << {
        tool: tool_call[:name],
        success: false,
        error: error.message
      }
    end
  end
  
  # Log tool usage
  execution.update!(
    tool_calls: (execution.tool_calls || []) + tool_calls.zip(results).map do |call, result|
      {
        name: call[:name],
        arguments: call[:arguments],
        result: result,
        executed_at: Time.current
      }
    end
  )
  
  results
end
```

## Error Handling and Recovery

### Execution Error Handling
```ruby
class Catalyst::ExecutionJob < ApplicationJob
  retry_on StandardError, wait: :exponentially_longer, attempts: 3
  
  discard_on Catalyst::SecurityError
  discard_on Catalyst::InvalidToolError
  
  def perform(execution_id)
    execution = Catalyst::Execution.find(execution_id)
    
    begin
      # Main execution logic
      result = execute_agent_logic(execution)
      
      execution.update!(
        status: :completed,
        result: result,
        completed_at: Time.current
      )
      
    rescue Catalyst::RetryableError => error
      # Let ActiveJob handle retries
      execution.update!(error_message: error.message)
      raise
      
    rescue => error
      # Non-retryable errors
      execution.update!(
        status: :failed,
        error_message: error.message,
        completed_at: Time.current
      )
      
      # Optional: Notify monitoring systems
      notify_error_tracking(error, execution)
      
      raise
    end
  end
end
```

## Interaction Tracking (IMPLEMENTED)

### Enhanced Execution Monitoring

Each execution now includes comprehensive interaction tracking:

```ruby
# During execution, interactions are automatically tracked
execution.increment_interaction!  # Called after each LLM response

# Monitor interaction patterns
execution.interaction_count      # => 3
execution.last_interaction_at    # => 2024-01-15 14:30:25 UTC

# Execution parameters are stored for analysis
execution.input_params = {
  model: "gpt-4.1-nano",
  temperature: 0.7,
  max_tokens: 1000
}
```

### Query Patterns for Monitoring

```ruby
# Find executions with high interaction counts
high_interaction_executions = Catalyst::Execution.where("interaction_count > ?", 5)

# Recent interactive executions
recent_interactive = Catalyst::Execution.where("interaction_count > 0")
                                      .order(:last_interaction_at)

# Analyze parameter usage
parameter_analysis = Catalyst::Execution.where.not(input_params: nil)
                                      .group("input_params->>'model'")
                                      .count
```

## Monitoring and Observability

### Execution Metrics
- **Execution Duration**: `completed_at - started_at`
- **Iteration Count**: Tracked in result metadata
- **Interaction Count**: New field tracking LLM interactions
- **Tool Usage**: Logged in `tool_calls` JSON field
- **Success Rate**: Percentage of completed vs failed executions
- **LLM Token Usage**: Tracked per execution for cost monitoring
- **Parameter Usage**: Stored in `input_params` for analysis

### Performance Monitoring
```ruby
# Example monitoring hook
module Catalyst
  module Monitoring
    def self.track_execution(execution)
      duration = execution.completed_at - execution.started_at
      
      # Custom metrics
      StatsD.timing("catalyst.execution.duration", duration)
      StatsD.increment("catalyst.execution.#{execution.status}")
      
      # Tool usage metrics
      execution.tool_calls&.each do |tool_call|
        StatsD.increment("catalyst.tool.#{tool_call['name']}.usage")
      end
    end
  end
end
```