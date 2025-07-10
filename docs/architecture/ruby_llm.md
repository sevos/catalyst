# RubyLLM Integration Architecture

## Overview

RubyLLM provides the foundational LLM integration layer for Catalyst, offering a unified Ruby interface for multiple AI providers while maintaining idiomatic Rails patterns.

## Core RubyLLM Patterns & Features

### 1. Chat Interface Pattern

RubyLLM's chat interface provides stateful conversation management:

```ruby
# Basic chat pattern
chat = RubyLLM.chat
response = chat.ask("What's the weather?")

# Model-specific chat
chat = RubyLLM.chat(model: 'gpt-4.1-nano')

# Conversation continuity
chat.ask("Tell me more about that")  # Maintains context
```

**Catalyst Application**: Each Execution becomes a persistent chat conversation.

### 2. ActiveRecord Integration Pattern

RubyLLM provides LLM provider abstraction without requiring ActiveRecord macros. Catalyst implements custom chat-like fields to avoid namespace pollution:

```ruby
class Execution < ApplicationRecord
  # Custom chat-like fields for interaction tracking
  # - interaction_count (integer)
  # - last_interaction_at (datetime)
  # - input_params (json, serialized)
  # No message content storage to avoid namespace pollution
end
```

**Benefits for Catalyst**:
- Clean namespace without `acts_as_chat`/`acts_as_message` pollution
- Custom interaction tracking tailored to agent needs
- Separation of concerns: RubyLLM handles LLM, Catalyst handles persistence
- Flexibility to store agent-specific metadata

### 3. Provider Abstraction Pattern

RubyLLM abstracts provider differences behind a unified interface:

```ruby
# Same interface, different providers
RubyLLM.chat(model: 'gpt-4.1-nano').ask(prompt)         # OpenAI
RubyLLM.chat(model: 'claude-3-haiku-20240307').ask(prompt)  # Anthropic
RubyLLM.chat(model: 'gemini-pro').ask(prompt)           # Google
```

**Catalyst Flexibility**: Agents can switch models without code changes.

### 4. Configuration Pattern

RubyLLM uses Rails-style configuration:

```ruby
RubyLLM.configure do |config|
  # Primary provider (OpenAI)
  config.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil) || 
                          Rails.application.credentials.dig(:catalyst, :openai_api_key)
  
  # Default models
  config.default_model = 'gpt-4.1-nano'
  config.default_embedding_model = 'text-embedding-3-small'
  
  # Additional providers
  config.anthropic_api_key = ENV.fetch('ANTHROPIC_API_KEY', nil) || 
                             Rails.application.credentials.dig(:catalyst, :anthropic_api_key)
  config.gemini_api_key = ENV.fetch('GEMINI_API_KEY', nil) || 
                          Rails.application.credentials.dig(:catalyst, :gemini_api_key)
  
  # Connection settings
  config.request_timeout = 120
  config.max_retries = 3
  
  # Logging
  config.log_file = Rails.root.join('log/ruby_llm.log')
  config.log_level = Rails.env.development? ? :debug : :info
end
```

**Integration Point**: Catalyst's install generator will create this configuration.

### 5. Tool/Function Calling Pattern

RubyLLM provides a clean tool interface for extending LLM capabilities:

```ruby
class DatabaseQuery < RubyLLM::Tool
  description "Query application database"
  param :query, desc: "SQL query to execute"
  
  def execute(query:)
    # Implementation
  end
end

chat.with_tool(DatabaseQuery.new)
```

**Future Catalyst Tools** (Epic 2): Direct inheritance from `RubyLLM::Tool`.

### 6. Streaming Response Pattern

RubyLLM supports real-time streaming with blocks:

```ruby
chat.ask("Tell me a story") do |chunk|
  print chunk.content  # Real-time output
end
```

**Catalyst UI** (Epic 3): Enable real-time agent response display.

### 7. Multi-Modal Pattern

RubyLLM handles various input types seamlessly:

```ruby
# Text with images
chat.ask("What's in this image?", with: "diagram.png")

# Multiple files
chat.ask("Analyze these", with: ["doc.pdf", "data.csv"])
```

**Catalyst Enhancement**: Agents could process diverse inputs.

### 8. Error Handling Pattern

RubyLLM provides consistent error handling:

```ruby
begin
  response = chat.ask(prompt)
rescue RubyLLM::RateLimitError => e
  # Handle rate limiting
rescue RubyLLM::APIError => e
  # Handle API errors
end
```

**Catalyst Reliability**: Consistent error handling across providers.

## Key RubyLLM Capabilities for Catalyst

### 1. **Conversation Persistence**
- Built-in message storage
- Conversation replay
- Context window management
- Automatic truncation handling

### 2. **Provider Flexibility**
- Switch providers without code changes
- Fallback provider support
- Cost optimization through provider selection
- Local model support (Ollama)

### 3. **Rails Integration**
- ActiveRecord macros
- Rails credential management
- Standard Rails patterns
- Migration generators

### 4. **Developer Experience**
- Simple, intuitive API
- Block-based streaming
- Comprehensive documentation
- Testing utilities included

## Architecture Benefits for Catalyst

### Direct Integration Advantages

1. **Clean Separation**: Use RubyLLM as LLM service, custom persistence layer
2. **Rails Conventions**: Follows Rails patterns developers expect
3. **Minimal Configuration**: Simple setup through initializer
4. **Future-Proof**: Easy upgrades as RubyLLM evolves

### Execution as Chat Benefits

1. **Interaction Tracking**: Custom fields for counting and timing
2. **Input Parameter Storage**: Agent-specific parameter persistence
3. **Debugging Support**: Execution metadata visibility
4. **Analytics Ready**: Query interaction patterns and parameters

### Model Management Benefits

1. **Per-Agent Models**: Each agent can use different models
2. **Dynamic Switching**: Change models at runtime
3. **Cost Control**: Use appropriate models for each task
4. **A/B Testing**: Compare model performance

## Integration Points

### 1. **Installation Generator**
```bash
rails g catalyst:install
# Generates RubyLLM initializer
# Prompts for API keys
# Creates necessary migrations
```

### 2. **Execution Model (IMPLEMENTED)**
```ruby
class Catalyst::Execution < ApplicationRecord
  # Chat-like tracking fields without acts_as_chat
  serialize :input_params, coder: JSON
  
  # Interaction tracking methods
  def increment_interaction!
    self.interaction_count = (interaction_count || 0) + 1
    self.last_interaction_at = Time.current
    save!
  end
  
  # Query patterns
  scope :with_interactions, -> { where('interaction_count > 0') }
  scope :recent_interactions, -> { order(:last_interaction_at) }
end
```

### 3. **Configuration (IMPLEMENTED)**
```ruby
# config/initializers/ruby_llm.rb
RubyLLM.configure do |config|
  # Primary provider with credentials fallback
  config.openai_api_key = ENV.fetch('OPENAI_API_KEY', nil) || 
                          Rails.application.credentials.dig(:catalyst, :openai_api_key)
  
  # Production defaults
  config.default_model = 'gpt-4.1-nano'
  config.request_timeout = 120
  config.max_retries = 3
  
  # Environment-specific logging
  config.log_level = Rails.env.development? ? :debug : :info
end
```

## Future Extensibility

### Tool System (Epic 2)
- Inherit from `RubyLLM::Tool`
- Automatic parameter validation
- Built-in documentation

### Streaming UI (Epic 3)
- Use RubyLLM's streaming blocks
- Real-time token display
- Progress indicators

### Multi-Tenancy (Epic 4)
- Per-tenant API keys
- Model access control
- Usage tracking

## Security Considerations

RubyLLM provides several security features:

1. **Credential Management**: Rails credentials integration
2. **Input Sanitization**: Automatic prompt cleaning
3. **Rate Limiting**: Provider-level protections
4. **Error Masking**: Safe error messages

## Performance Patterns

1. **Connection Pooling**: Via Faraday
2. **Batch Processing**: For embeddings
3. **Streaming**: Reduces time-to-first-token
4. **Caching**: Optional response caching

## Testing Support

RubyLLM includes testing utilities:

```ruby
# Mock LLM responses
RubyLLM.test_mode!
RubyLLM.mock_response("Expected response")

# Assertion helpers
assert_llm_asked("Expected prompt")
```

## Conclusion

RubyLLM's patterns align perfectly with Catalyst's goals:
- Rails-native design philosophy
- Simple, powerful abstractions
- Production-ready features
- Extensible architecture

By leveraging RubyLLM as a service layer with custom persistence, Catalyst can focus on agent orchestration and business logic while delegating LLM complexity to a well-tested, actively maintained library without namespace pollution.