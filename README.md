# Catalyst Framework

A Ruby on Rails engine for orchestrating AI agents with built-in observability, multi-tenancy, and asynchronous processing.

## 🚧 Development Status

**Current Status:** Early Development - Epic 1 in Progress  
**Progress:** 6/16 stories complete (37.5%)

### Epic Progress
| Epic | Progress | Status |
|------|----------|--------|
| **Epic 1: "Hello, Agent!" Experience** | 6/8 (75%) | 🟡 **In Progress** |
| Epic 2: "Useful Agent" - Tooling & Outputs | 0/3 (0%) | ⏸️ Pending |
| Epic 3: "Observable Agent" - UI | 0/2 (0%) | ⏸️ Pending |
| Epic 4: "Secure & Production-Ready Agent" | 0/3 (0%) | ⏸️ Pending |

### ✅ Completed Features
- **Core Models & Installation** - Rails generator with Agent and Execution models
- **Model Structure Alignment** - LLM configuration and execution tracking
- **Prompt File Generation** - Consistent generator behavior across framework
- **Agent Generation** - `rails g catalyst:agent` for creating custom agents
- **RubyLLM Integration** - Multi-provider LLM support (OpenAI, Anthropic, Gemini)
- **Single Agent Execution API** - Synchronous agent execution with comprehensive tracking

### 🔄 Next Up
- **Agentic Iteration Loop & Limits** - Max iterations control for agent reasoning
- **Asynchronous Execution** - ActiveJob integration for background processing

## Installation

⚠️ **Note:** This gem is currently in early development and not yet published.

For development/testing:

```ruby
# Add to your Rails application's Gemfile
gem "catalyst", path: "path/to/catalyst"
```

Then run:
```bash
bundle install
rails g catalyst:install
```

## Quick Start

1. **Install the framework:**
   ```bash
   rails g catalyst:install
   rails db:migrate
   ```

2. **Create an agent:**
   ```bash
   rails g catalyst:agent MyAgent
   ```

3. **Configure API keys** (see `config/initializers/ruby_llm.rb`)

4. **Execute your agent:**
   ```ruby
   # Create an agent
   agent = ApplicationAgent.create!(
     role: "Marketing Assistant",
     goal: "Create compelling marketing content",
     backstory: "Expert in brand marketing",
     agent_attributes: {
       name: "Marketing Agent",
       model: "gpt-4.1-nano"
     }
   )
   
   # Execute synchronously
   response = agent.execute("Create a tagline for a new coffee shop")
   puts response
   # => "Brew Your Dreams, One Cup at a Time"
   
   # Check execution history
   agent.executions.last.status  # => "completed"
   agent.executions.last.duration  # => 2.3 seconds
   ```

## Documentation

- **[Product Requirements](docs/prd.md)** - Complete feature specifications
- **[Architecture](docs/architecture.md)** - Technical design and patterns  
- **[Epic 1 Progress](docs/epics/epic-1-hello-agent-experience.md)** - Current development status

## Contributing

This project is in active development. See our [PRD](docs/prd.md) for the complete roadmap.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
