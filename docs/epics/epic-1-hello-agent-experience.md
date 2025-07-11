# Epic 1: The "Hello, Agent!" Experience

## Epic Goal
Enable a developer to generate and run a basic agent asynchronously, establishing the core execution loop and foundational infrastructure for the Catalyst framework.

## Epic Description

**Problem Statement:**
Developers need a simple, Rails-native way to create and execute AI agents without dealing with complex AI infrastructure or integration challenges.

**Solution Overview:**
Create the foundational components of the Catalyst framework that allow developers to generate, configure, and execute basic AI agents through familiar Rails patterns.

**Value Proposition:**
- Provides the core foundation for all AI agent functionality
- Enables developers to get started quickly with AI agents
- Establishes patterns that scale to more complex agent behaviors

## Stories

### 1.1: Core Models & Installation ✅ **COMPLETED**
Create the fundamental ActiveRecord models (Agent, Execution) and installation generator that provide the persistent foundation for all framework operations.

### 1.1.1: Model Structure Alignment ✅ **COMPLETED**
Align the Catalyst::Agent model structure with documented architecture requirements by adding LLM configuration fields (name, model, model_params), enhancing execution tracking, and updating defaults to support agentic behavior.

### 1.1.2: Prompt File Generation for ApplicationAgent ✅ **COMPLETED**
Add prompt file generation to `rails g catalyst:install` to match the behavior of `rails g catalyst:agent`, ensuring consistent developer experience across all Catalyst generators.

### 1.2: Agent Generation & Configuration ✅ **COMPLETED**
Build a Rails generator that creates agent classes and prompt templates, enabling developers to quickly define new AI agents with role, goal, and backstory.

### 1.2.1: RubyLLM Integration ✅ **COMPLETED**
Integrate RubyLLM as the LLM provider layer, adding the dependency, configuration initializer, and ActiveRecord integration to enable unified access to multiple AI providers.

### 1.3: Single Agent Execution API ✅ **COMPLETED**
Implement single agent execution capability that processes agent configuration, input parameters, and user messages to generate system prompts and execute single LLM requests via RubyLLM integration.

### 1.4: Agentic Iteration Loop & Limits
Add max_iterations configuration to control agent reasoning loops, preventing runaway executions and providing cost control.

### 1.5: Asynchronous Execution via ActiveJob
Wrap agent execution in ActiveJob to enable non-blocking asynchronous execution through Rails' job queue system.

## Dependencies
- Rails application environment
- ActiveRecord for data persistence
- ActiveJob for background processing
- RubyLLM integration for LLM provider access

## Success Criteria
- [x] Developer can install the framework with `rails g catalyst:install`
- [x] Install generator creates prompt files consistently with agent generator
- [x] Developer can generate a new agent with `rails g catalyst:agent MyAgent`
- [x] Agent can be executed synchronously with `agent.execute("message")`
- [ ] Agent can be executed asynchronously with `MyAgent.perform_later("prompt")`
- [x] Execution results are persisted and accessible
- [x] Framework handles errors gracefully
- [ ] Cost control through max_iterations works correctly

## Definition of Done
- [ ] All 8 stories completed with acceptance criteria met (Stories 1.1, 1.1.1, 1.1.2, 1.2, 1.2.1, 1.3, 1.4, 1.5)
  - ✅ Story 1.1: Done
  - ✅ Story 1.1.1: Done
  - ✅ Story 1.1.2: Done (prompt file generation gap fixed)
  - ✅ Story 1.2: Done
  - ✅ Story 1.2.1: Done (RubyLLM integration complete)
  - ✅ Story 1.3: Done
  - ⏳ Story 1.4: Draft
  - ⏳ Story 1.5: Draft
- [x] Framework can be installed in a Rails application
- [x] Agent generation works (`rails g catalyst:agent MyAgent`)
- [x] Basic agent execution works end-to-end
- [ ] Documentation covers installation and basic usage
- [x] Tests verify all functionality (for completed stories)
- [ ] No security vulnerabilities in basic implementation

## Timeline
**Target: Sprint 1-2** | **Progress: 6/8 stories complete (75%)**

- Stories 1.1, 1.1.1, 1.1.2: Foundation & Setup (Sprint 1) 
  - ✅ Story 1.1: **COMPLETED**
  - ✅ Story 1.1.1: **COMPLETED**
  - ✅ Story 1.1.2: **COMPLETED** (Bug fix - prompt generation gap)
- Story 1.2, 1.2.1: Agent Generation & LLM Setup (Sprint 1)
  - ✅ Story 1.2: Agent Generation **COMPLETED**
  - ✅ Story 1.2.1: RubyLLM Integration **COMPLETED**
- Stories 1.3-1.5: Execution & Enhanced Capabilities (Sprint 1-2)
  - ✅ Story 1.3: Single Agent Execution API - **COMPLETED**
  - ⏳ Stories 1.4-1.5: Advanced Features (Sprint 2) - **NEXT UP**

## Risks & Mitigation
- **Risk:** LLM provider API reliability
  - **Mitigation:** Leverage RubyLLM's built-in error handling and retry logic
- **Risk:** ActiveJob configuration complexity
  - **Mitigation:** Provide clear documentation and sensible defaults
- **Risk:** Performance impact of synchronous execution
  - **Mitigation:** Emphasize asynchronous execution in documentation

## Notes
This epic establishes the foundation for the entire Catalyst framework. All subsequent epics depend on these core capabilities being implemented correctly.