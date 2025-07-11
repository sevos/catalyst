# Execution Flow Architecture

## Overview

The Catalyst Framework's execution flow is designed around **synchronous processing** for immediate agent responses. This provides simple, predictable behavior for single agent execution with direct LLM integration via RubyLLM.

## Execution Phases

### 1. Agent Creation
```ruby
# From host application - create agent with nested attributes
agent = ApplicationAgent.create!(
  role: "Marketing Assistant",
  goal: "Create compelling marketing content",
  backstory: "Expert in brand marketing",
  agent_attributes: {
    name: "Marketing Agent",
    model: "gpt-4.1-nano",
    model_params: { "temperature" => 0.7 }
  }
)
```

### 2. Direct Execution
```ruby
# Synchronous execution with immediate response
response = agent.execute("Create a marketing campaign for our new product")
# => "Here's a comprehensive marketing campaign for your product..."

# Alternative syntax using delegated types
response = agent.catalyst_agent.execute("Create a marketing campaign for our new product")
```

### 3. Execution Flow Implementation
```ruby
# Catalyst::Agent#execute method (actual implementation)
def execute(user_message)
  # 1. Input validation
  validate_user_message!(user_message)
  
  # 2. Create execution record
  execution = create_execution_record(user_message)
  
  begin
    # 3. Update status to running
    execution.start!
    
    # 4. Build system prompt from ERB template
    system_prompt = build_system_prompt
    
    # 5. Send to LLM via RubyLLM
    llm_response = send_to_llm(system_prompt, user_message)
    
    # 6. Complete execution with results
    execution.complete!(llm_response)
    execution.increment_interaction!
    
    # 7. Return response
    llm_response
  rescue => error
    # 8. Handle errors safely
    handle_execution_error(execution, error)
    raise
  end
end

private

def create_execution_record(user_message)
  executions.create!(
    prompt: user_message.strip,
    input_params: capture_agent_attributes,
    interaction_count: 0
  )
end

def capture_agent_attributes
  # Merge both Catalyst::Agent and agentable attributes
  agent_attrs = attributes.except("id", "created_at", "updated_at")
  agentable_attrs = agentable.attributes.except("id", "created_at", "updated_at")
  agent_attrs.merge(agentable_attrs)
end
```

## Template System Implementation

### ERB Template Resolution
```ruby
# Template resolution with inheritance chain support
def build_system_prompt
  template_content = load_prompt_template
  ERB.new(template_content).result(binding_with_agent)
end

def load_prompt_template
  template_path = resolve_template_path
  File.read(template_path)
rescue Errno::ENOENT => e
  raise TemplateNotFoundError, "Template file not found: #{template_path}"
end

def resolve_template_path
  template_paths = build_template_inheritance_chain
  
  template_paths.each do |path|
    return path if File.exist?(path)
  end
  
  raise TemplateNotFoundError, "No template found for #{agentable.class.name}. Checked: #{template_paths.join(', ')}"
end

def build_template_inheritance_chain
  paths = []
  klass = agentable.class
  
  # Walk up the inheritance chain until we hit ApplicationRecord
  while klass && klass != ApplicationRecord
    template_name = klass.name.underscore
    paths << Rails.root.join("app/ai/prompts", "#{template_name}.md.erb").to_s
    klass = klass.superclass
  end
  
  paths
end

def binding_with_agent
  @agent = agentable  # Make agentable available as @agent in templates
  binding
end
```

## LLM Integration

### RubyLLM Implementation
```ruby
# Direct RubyLLM integration (actual implementation)
def send_to_llm(system_prompt, user_message)
  chat = RubyLLM.chat(
    model: model || DEFAULT_MODEL,
    **formatted_model_params
  )
  
  chat.system(system_prompt)
  response = chat.ask(user_message)
  
  response.to_s
end

def formatted_model_params
  return {} unless model_params
  
  # Convert string keys to symbols for RubyLLM
  model_params.transform_keys(&:to_sym)
end

# Example usage with different models and parameters
agent = ApplicationAgent.create!(
  role: "Assistant",
  goal: "Help users",
  backstory: "Helpful AI assistant",
  agent_attributes: {
    name: "Test Agent",
    model: "gpt-4.1-mini",
    model_params: { "temperature" => 0.7, "max_tokens" => 500 }
  }
)

response = agent.execute("Hello, how can you help me?")
# => LLM response processed through RubyLLM
```

## Error Handling and Security

### Input Validation
```ruby
def validate_user_message!(user_message)
  raise ArgumentError, "User message cannot be blank" if user_message.blank?
  raise ArgumentError, "User message must be a string" unless user_message.is_a?(String)
  raise ArgumentError, "User message too long (maximum 10,000 characters)" if user_message.length > 10_000
end
```

### Secure Error Handling
```ruby
def handle_execution_error(execution, error)
  # Safely handle errors without risking validation failures
  sanitized_message = sanitize_error_message(error.message)
  execution.update_columns(
    status: "failed",
    error_message: sanitized_message,
    completed_at: Time.current
  )
end

def sanitize_error_message(message)
  # Remove potentially sensitive information from error messages
  message.to_s.gsub(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/, "[EMAIL]")
             .gsub(/\b(?:\d{1,3}\.){3}\d{1,3}\b/, "[IP]")
             .gsub(/\b[A-Za-z0-9]{20,}\b/, "[TOKEN]")
             .truncate(500)
end
```

## Execution Status Management

### Status Transitions
```ruby
# Execution model with enum status
class Catalyst::Execution < ApplicationRecord
  enum :status, {
    pending: "pending",
    running: "running", 
    completed: "completed",
    failed: "failed"
  }, default: :pending
  
  # Helper methods for status transitions
  def start!
    update!(status: :running, started_at: Time.current)
  end
  
  def complete!(result = nil)
    update!(status: :completed, completed_at: Time.current, result: result)
  end
  
  def fail!(error_message = nil)
    update!(status: :failed, completed_at: Time.current, error_message: error_message)
  end
  
  # Interaction tracking
  def increment_interaction!
    self.interaction_count = (interaction_count || 0) + 1
    self.last_interaction_at = Time.current
    save!
  end
end
```

## Monitoring and Observability

### Execution Tracking
Each execution captures comprehensive data for monitoring:

```ruby
# Execution attributes tracked
execution = agent.execute("Hello, how can you help me?")

# Access execution details
last_execution = agent.executions.last
last_execution.status              # => "completed"
last_execution.interaction_count   # => 1
last_execution.input_params        # => {"name" => "Test Agent", "model" => "gpt-4.1-nano", ...}
last_execution.prompt              # => "Hello, how can you help me?"
last_execution.result              # => "I'm here to help with..."
last_execution.duration            # => 2.5 seconds
```

### Query Patterns for Monitoring
```ruby
# Find recent executions
recent_executions = Catalyst::Execution.order(created_at: :desc).limit(10)

# Monitor success rates
success_rate = Catalyst::Execution.where(status: :completed).count / 
               Catalyst::Execution.count.to_f * 100

# Find failed executions for debugging
failed_executions = Catalyst::Execution.where(status: :failed)
                                      .includes(:agent)
                                      .order(created_at: :desc)

# Analyze model usage
model_usage = Catalyst::Execution.joins(:agent)
                                .group("catalyst_agents.model")
                                .count

# Monitor execution performance
slow_executions = Catalyst::Execution.where("completed_at - started_at > ?", 5.seconds)
```

### Key Metrics Tracked
- **Execution Duration**: `completed_at - started_at`
- **Interaction Count**: Number of LLM interactions per execution
- **Success Rate**: Percentage of completed vs failed executions
- **Input Parameters**: Complete agent configuration captured per execution
- **Error Patterns**: Sanitized error messages for debugging
- **Model Usage**: Which models are being used most frequently

### Example Monitoring Implementation
```ruby
# Track execution metrics
module Catalyst
  module Monitoring
    def self.track_execution(execution)
      return unless execution.finished?
      
      duration = execution.duration
      
      # Custom metrics (using your preferred metrics library)
      StatsD.timing("catalyst.execution.duration", duration)
      StatsD.increment("catalyst.execution.#{execution.status}")
      
      # Model usage tracking
      model = execution.input_params["model"] || "default"
      StatsD.increment("catalyst.model.#{model}.usage")
    end
  end
end
```
