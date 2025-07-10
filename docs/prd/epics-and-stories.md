# Epics & Stories

## Epic 1: The "Hello, Agent!" Experience

**Goal:** Enable a developer to generate a basic agent, configure it with a prompt, execute a simple task asynchronously via ActiveJob, and successfully get a result from a default LLM.

* **Story 1.1: Core Models & Installation**  
  * Create Agent and Execution ActiveRecord models and an installation generator for migrations.  
* **Story 1.2: Agent Generation & Configuration**  
  * Create a Rails generator (rails g catalyst:agent) for Agent classes and ERB prompt templates.  
* **Story 1.3: Single Agent Execution API**  
  * Implement single agent execution capability that processes agent configuration, input parameters, and user messages to generate system prompts and execute single LLM requests via RubyLLM integration.  
* **Story 1.4: Agentic Iteration Loop & Limits**  
  * Implement a max\_iterations limit for an Agent to control its reasoning loop.  
* **Story 1.5: Asynchronous Execution via ActiveJob**  
  * Wrap the agent execution logic in an ActiveJob to be triggered via perform\_later.

## Epic 2: The "Useful Agent" — Tooling & Outputs

**Goal:** Empower the agent to perform useful work by calling registered Tool Objects and returning validated, structured data using an ActiveModel schema.

* **Story 2.1: Reusable Tool Definition & Registration**  
  * Define a standard interface for standalone Tool objects and allow them to be registered with an Agent. Enforce keyword arguments for tools.  
* **Story 2.2: Tool Execution Loop**  
  * Enhance the agent's iteration loop to support a "ReAct" pattern: parse a tool call from the LLM, execute the tool's \#call method, and return the result to the agent's context.  
* **Story 2.3: Robust Structured Output & Self-Correction**  
  * Implement the output\_schema feature, allowing an agent to attempt to self-correct its JSON output if it fails ActiveModel validation.

## Epic 3: The "Observable Agent" (Proof-of-Concept UI)

**Goal:** To provide early visibility by building the backend logging for execution traces and creating a proof-of-concept dashboard to display them.

* **Story 3.1: Basic Execution Monitoring**  
  * Create an Execution model that stores initial input and final output. Build a dashboard index page and a simple show page to display this data, styled with Tailwind and updated via Hotwire.  
* **Story 3.2: Detailed Execution Trace**  
  * Create an ExecutionStep model to log detailed events (thoughts, tool calls). Enhance the execution show page to display this full, real-time chronological trace.

## Epic 4: The "Secure & Production-Ready Agent"

**Goal:** To harden the framework for production by implementing the secure context model and providing clear integration points for multi-tenancy.

* **Story 4.1: Research Secure Context & MCP Compatibility**  
  * Analyze best practices for secure context injection and their alignment with the Model Context Protocol (MCP), producing an Architectural Decision Record (ADR).  
* **Story 4.2: Implement Secure Context Passing**  
  * Implement the chosen secure context mechanism, allowing tools to declare their data needs and receive only those values from the context.  
* **Story 4.3: Multi-Tenancy Integration Support**  
  * Update models and jobs to support tenant scoping and provide comprehensive documentation for integrating with gems like acts\_as\_tenant.  
* **Story 4.4: Secure Tool Argument Passing**  
  * Enhance the tool schema to allow marking certain arguments as "context-provided," which are securely injected by the framework and hidden from the LLM.