# Data Model Architecture

## Core Data Strategy

The Catalyst Framework uses a **Delegated Types** approach to provide both simplicity for new users and unlimited flexibility for advanced use cases.

## Primary Models

### Catalyst::Agent (Base Model)
```ruby
# Core attributes common to all agents
class Catalyst::Agent < ApplicationRecord
  delegated_type :agentable, types: %w[ApplicationAgent MarketingAgent CustomAgent]
  
  # Core shared attributes
  # - id (primary key)
  # - name (string)
  # - description (text)
  # - agentable_type (string) - for delegated types
  # - agentable_id (integer) - for delegated types
  # - created_at, updated_at (timestamps)
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
    
    # Validation helpers
    validates :system_prompt, presence: true, if: :requires_system_prompt?
    
    # Common agent behavior
    def execute(prompt, context: {})
      agent.execute(prompt, context: context)
    end
    
    def recent_executions(limit = 10)
      agent.executions.order(created_at: :desc).limit(limit)
    end
  end
  
  private
  
  def requires_system_prompt?
    respond_to?(:system_prompt)
  end
end
```

### ApplicationAgent (Entry Point)
```ruby
# Simple agent type for getting started
class ApplicationAgent < ApplicationRecord
  include Catalyst::Agentable
  
  # Specific attributes for application agents
  # - system_prompt (text)
  # - model (string, default: "gpt-4")
  # - temperature (float, default: 0.7)
  # - max_tokens (integer, default: 1000)
  # - max_iterations (integer, default: 5)
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
  
  # Execution state and results
  # - id (primary key)
  # - agent_id (foreign key)
  # - status (enum: pending, running, completed, failed)
  # - prompt (text) - the constructed prompt sent to LLM
  # - response (text) - the LLM response
  # - tool_calls (json) - array of tool invocations
  # - result (json) - final structured result
  # - error_message (text) - if execution failed
  # - started_at, completed_at (timestamps)
  # - metadata (json) - additional execution context
end
```

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

### Initial Schema
```ruby
# Core tables created by engine installation
create_table :catalyst_agents do |t|
  t.string :name, null: false
  t.text :description
  t.string :agentable_type, null: false
  t.bigint :agentable_id, null: false
  t.timestamps
  
  t.index [:agentable_type, :agentable_id], unique: true
end

create_table :application_agents do |t|
  t.text :system_prompt
  t.string :model, default: "gpt-4"
  t.float :temperature, default: 0.7
  t.integer :max_tokens, default: 1000
  t.integer :max_iterations, default: 5
  t.timestamps
end

create_table :catalyst_executions do |t|
  t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }
  t.integer :status, default: 0
  t.text :prompt
  t.text :response
  t.json :tool_calls
  t.json :result
  t.text :error_message
  t.datetime :started_at
  t.datetime :completed_at
  t.json :metadata
  t.timestamps
end
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
```