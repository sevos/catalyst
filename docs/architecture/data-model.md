# Data Model Architecture

## Core Data Strategy

The Catalyst Framework uses a **Delegated Types** approach to provide both simplicity for new users and unlimited flexibility for advanced use cases.

## Primary Models

### Catalyst::Agent (Base Model)
```ruby
# Core attributes common to all agents
class Catalyst::Agent < ApplicationRecord
  delegated_type :agentable, types: %w[ApplicationAgent MarketingAgent CustomAgent]
  
  # Core shared attributes (CURRENT IMPLEMENTATION)
  # - id (primary key)
  # - agentable_type (string, null: false) - for delegated types
  # - agentable_id (bigint, null: false) - for delegated types
  # - max_iterations (integer, default: 5, null: false)
  # - created_at, updated_at (timestamps)
  
  # IMPLEMENTED ATTRIBUTES:
  # - name (string, null: false) - agent display name
  # - model (string) - LLM model selection (e.g., "gpt-4.1-nano")
  # - model_params (text) - serializable JSON containing LLM parameters
  #   Examples: {"temperature": 0.1, "max_tokens": 1000, "top_p": 0.9}
  
  # Note: Agent prompts are defined in *.md.erb template files, not stored in database
end
```

### Catalyst::Agentable Module
```ruby
# Module that provides delegated type behavior for agent types
module Catalyst::Agentable
  extend ActiveSupport::Concern
  
  included do
    # Provides the reverse relationship for delegated types
    has_one :agent, as: :agentable, class_name: "Catalyst::Agent", dependent: :destroy
    
    # Common agent behavior
    def execute(prompt, context: {})
      agent.execute(prompt, context: context)
    end
    
    def recent_executions(limit = 10)
      agent.executions.order(created_at: :desc).limit(limit)
    end
  end
end
```

### ApplicationAgent (Entry Point)
```ruby
# Simple agent type for getting started
class ApplicationAgent < ApplicationRecord
  include Catalyst::Agentable
  
  # Basic agent configuration attributes (CURRENT IMPLEMENTATION)
  # - id (primary key)
  # - role (string) - What the agent is (e.g., "Marketing Assistant", "Data Analyst")
  # - goal (text) - What the agent is trying to accomplish
  # - backstory (text) - Agent's background and expertise context
  # - created_at, updated_at (timestamps)
  
  # Note: LLM configuration (model, model_params, etc.) is handled by base Catalyst::Agent
  # Agent prompts are constructed from role/backstory/goal using *.md.erb templates
end
```

### Custom Agent Types
```ruby
# Example: Advanced marketing agent
class MarketingAgent < ApplicationRecord
  include Catalyst::Agentable
  
  # Marketing-specific attributes
  # - campaign_type (string)
  # - target_audience (json)
  # - brand_guidelines (text)
  # - approved_channels (array)
  # - budget_constraints (json)
end
```

## Execution Tracking

### Catalyst::Execution
```ruby
class Catalyst::Execution < ApplicationRecord
  belongs_to :agent, class_name: "Catalyst::Agent"
  
  # Execution state and results (CURRENT IMPLEMENTATION)
  # - id (primary key)
  # - agent_id (integer, null: false, foreign key)
  # - status (string, null: false) - implemented as enum on model level
  # - prompt (text, null: false) - the constructed prompt sent to LLM
  # - result (text) - execution result/response from LLM
  # - metadata (json) - additional execution context
  # - created_at, updated_at (timestamps)
  
  # IMPLEMENTED ATTRIBUTES:
  # - error_message (text) - if execution failed
  # - started_at (datetime) - when execution began
  # - completed_at (datetime) - when execution finished
  # - interaction_count (integer, default: 0) - tracks LLM interactions per execution
  # - last_interaction_at (datetime) - timestamp of most recent interaction
  # - input_params (text, JSON serialized) - execution-specific parameters
  
  # Note: Status enum values defined in model: pending, running, completed, failed
end
```

## Attribute Placement Strategy

### What Belongs in Catalyst::Agent (Base Model)

**Currently Implemented:**
- **Delegated types metadata**: `agentable_type`, `agentable_id`
- **Basic configuration**: `max_iterations`
- **Timestamps**: `created_at`, `updated_at`

**Currently Implemented:**
- **Common identification**: `name` (required)
- **LLM configuration**: `model`, `model_params` (serializable JSON)
- **Enhanced max_iterations**: Default value of 5 for multi-step reasoning

**Rationale**: These attributes are common to ALL agent types and form the foundation of agent behavior.

### What Belongs in Delegated Types (e.g., ApplicationAgent)
- **Agent personality**: `role`, `backstory`, `goal` (for ApplicationAgent)
- **Domain-specific configuration**: `campaign_type`, `brand_guidelines` (for MarketingAgent)
- **Specialized behavior parameters**: Custom attributes that modify agent behavior
- **Type-specific constraints**: Validation rules unique to that agent type

**Rationale**: These attributes define what makes each agent type unique and specialized.

### What Belongs in External Files
- **Agent prompts**: Defined in `*.md.erb` template files for maintainability
- **Tool definitions**: Separate tool classes for reusability
- **Validation logic**: Complex business rules in model methods

**Rationale**: Code and templates are more maintainable outside the database schema.

## Database Schema Benefits

### Multi-Tenancy Support
- All models include tenant isolation capabilities
- Secure context passing between components
- Clean separation of data per tenant

### Observability
- Complete execution audit trail
- Tool usage tracking
- Performance monitoring data
- Error tracking and debugging

### Extensibility
- Easy to add new agent types without schema changes
- Delegated types provide type-safe customization
- JSON fields for flexible metadata storage

## Migration Strategy

### Current Schema (As Implemented)
```ruby
# Core tables created by engine installation
create_table :catalyst_agents do |t|
  t.string :agentable_type, null: false
  t.bigint :agentable_id, null: false
  t.integer :max_iterations, default: 5, null: false
  t.timestamps
  
  t.index [:agentable_type, :agentable_id], unique: true, name: "index_catalyst_agents_on_agentable"
end

create_table :application_agents do |t|
  t.string :role
  t.text :goal
  t.text :backstory
  t.timestamps
end

create_table :catalyst_executions do |t|
  t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }
  t.string :status, null: false
  t.text :prompt, null: false
  t.text :result
  t.json :metadata
  t.timestamps
end
```

### Current Schema (Fully Implemented)
```ruby
# Current production schema with all features implemented
create_table :catalyst_agents do |t|
  t.string :name, null: false
  t.string :agentable_type, null: false
  t.bigint :agentable_id, null: false
  t.string :model
  t.text :model_params  # Serializable JSON: {"temperature": 0.1, "max_tokens": 1000}
  t.integer :max_iterations, default: 5, null: false
  t.timestamps
  
  t.index [:agentable_type, :agentable_id], unique: true, name: "index_catalyst_agents_on_agentable"
end

create_table :catalyst_executions do |t|
  t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }
  t.string :status, null: false  # Enum: pending, running, completed, failed
  t.text :prompt, null: false
  t.text :result
  t.text :error_message
  t.datetime :started_at
  t.datetime :completed_at
  t.integer :interaction_count, default: 0, null: false
  t.datetime :last_interaction_at
  t.text :input_params  # Serializable JSON for execution parameters
  t.json :metadata
  t.timestamps
end
```

## Enhanced Features

### Nested Attributes Pattern (IMPLEMENTED)

The Agentable pattern supports nested attributes for streamlined agent creation:

```ruby
# Create agent with nested catalyst_agent configuration
application_agent = ApplicationAgent.create!(
  role: "Marketing Assistant",
  goal: "Create compelling marketing content",
  backstory: "Expert in brand marketing and copywriting",
  agent_attributes: {
    name: "Marketing Agent",
    max_iterations: 10,
    model: "gpt-4.1-nano",
    model_params: { "temperature" => 0.7, "max_tokens" => 1000 }
  }
)

# Alternative syntax using catalyst_agent_attributes
application_agent = ApplicationAgent.create!(
  role: "Data Analyst",
  goal: "Analyze business data",
  backstory: "Expert in data science",
  catalyst_agent_attributes: {
    name: "Data Agent",
    max_iterations: 15
  }
)
```

### Interaction Tracking (IMPLEMENTED)

Each execution tracks interaction patterns for monitoring and debugging:

```ruby
# Track interactions during execution
execution.increment_interaction!

# Store execution-specific parameters
execution.update!(input_params: {
  model: "gpt-4.1-nano",
  temperature: 0.7,
  max_tokens: 1000
})

# Monitor interaction patterns
execution.interaction_count      # => 3
execution.last_interaction_at    # => 2024-01-15 14:30:25 UTC
execution.input_params          # => {"model" => "gpt-4.1-nano", "temperature" => 0.7}
```

## Query Patterns

### Finding Agents by Type
```ruby
# Find all marketing agents
marketing_agents = Catalyst::Agent.where(agentable_type: "MarketingAgent")

# Access specific agent attributes
agent = Catalyst::Agent.find(1)
agent.agentable.campaign_type # Marketing-specific attribute
```

### Execution Monitoring
```ruby
# Recent executions for an agent
agent.executions.order(created_at: :desc).limit(10)

# Failed executions for debugging
Catalyst::Execution.where(status: :failed).includes(:agent)

# Monitor interaction patterns
Catalyst::Execution.where("interaction_count > ?", 5).order(:last_interaction_at)
```