# **Catalyst Framework Product Requirements Document (PRD)**

## **1\. Goals and Background Context**

### **Goals**

* Establish this framework as the definitive open-source AI solution within the Rails community.  
* Foster an active, engaged, and collaborative community of users and contributors.  
* Generate inbound opportunities for specialized AI and Rails consulting work.

### **Background Context**

The Catalyst Framework addresses a critical gap in the Ruby on Rails ecosystem. Currently, developers lack a native, production-grade framework for orchestrating AI agents, as the most popular solutions are Python-exclusive. This forces developers to either leave the Rails ecosystem or build complex, brittle integrations. Catalyst aims to solve this by providing a truly open-source, Rails-idiomatic solution with built-in observability, multi-tenancy, and asynchronous processing, making advanced AI development accessible and practical within Rails.

### **Change Log**

| Date | Version | Description | Author |  
| | 1.0 | Initial PRD | John (PM) |

## **2\. Requirements**

### **Functional**

* **FR1:** The framework must provide a Rails generator (rails g catalyst:agent) to scaffold new Agent classes and their associated ERB prompt templates.  
* **FR2:** The Agent class must allow developers to define its core persona, including role, goal, and backstory.  
* **FR3:** An Agent must support the registration of standalone, reusable Tool objects.  
* **FR4:** The framework must automatically parse a Tool object's interface to make it available to the LLM.  
* **FR5:** Tasks must be executable asynchronously by default, using an ActiveJob backend (perform\_later).  
* **FR6:** The framework must provide a synchronous execution option (perform\_now) for testing and simple scripts.  
* **FR7:** A task must accept an ActiveModel class as an output\_schema to define and validate a structured output.  
* **FR8:** The framework must include a pre-built admin dashboard for observing task executions.  
* **FR9:** The dashboard's execution trace must log the final LLM prompt, the raw response, all tool calls with their inputs/outputs, and the final parsed output.

### **Non-Functional**

* **NFR1:** The framework must be multi-tenant aware, designed for easy integration with common tenancy gems like acts\_as\_tenant.  
* **NFR2:** A secure context object must be available to Tools without being exposed to the LLM prompt.  
* **NFR3:** The framework must support multiple LLM providers (Commercial APIs, aggregators like OpenRouter, and self-hosted models via Ollama).  
* **NFR4:** The admin dashboard will be styled with Tailwind CSS and use the Hotwire stack.  
* **NFR5:** It must be possible to configure a specific LLM for each individual Agent.  
* **NFR6:** The framework's public APIs, generators, and documentation must be designed with a focus on a high-quality developer experience.  
* **NFR7:** The framework must ship with comprehensive documentation, including a "Getting Started" guide.

## **3\. Technical Assumptions**

* **Repository Structure:** The framework will be developed and distributed as a Ruby gem, built as a Rails Engine.  
* **Service Architecture:** The core execution model will be built around ActiveJob, with a default recommendation for Solid Queue.  
* **Database Support:** The framework will support SQLite for basic functionality and assume PostgreSQL for advanced features like pgvector. It will be designed to leverage Rails' multiple-database support.  
* **Testing:** The framework itself will have comprehensive unit and integration test coverage.

## **4\. Epics & Stories**

### **Epic 1: The "Hello, Agent\!" Experience**

**Goal:** Enable a developer to generate a basic agent, configure it with a prompt, execute a simple task asynchronously via ActiveJob, and successfully get a result from a default LLM.

* **Story 1.1: Core Models & Installation**  
  * Create Agent and Execution ActiveRecord models and an installation generator for migrations.  
* **Story 1.2: Agent Generation & Configuration**  
  * Create a Rails generator (rails g catalyst:agent) for Agent classes and ERB prompt templates.  
* **Story 1.3: Default LLM Adapter & Basic Execution**  
  * Implement a default, configurable LLM adapter (e.g., for OpenAI) to execute a basic prompt.  
* **Story 1.4: Agentic Iteration Loop & Limits**  
  * Implement a max\_iterations limit for an Agent to control its reasoning loop.  
* **Story 1.5: Asynchronous Execution via ActiveJob**  
  * Wrap the agent execution logic in an ActiveJob to be triggered via perform\_later.

### **Epic 2: The "Useful Agent" — Tooling & Outputs**

**Goal:** Empower the agent to perform useful work by calling registered Tool Objects and returning validated, structured data using an ActiveModel schema.

* **Story 2.1: Reusable Tool Definition & Registration**  
  * Define a standard interface for standalone Tool objects and allow them to be registered with an Agent. Enforce keyword arguments for tools.  
* **Story 2.2: Tool Execution Loop**  
  * Enhance the agent's iteration loop to support a "ReAct" pattern: parse a tool call from the LLM, execute the tool's \#call method, and return the result to the agent's context.  
* **Story 2.3: Robust Structured Output & Self-Correction**  
  * Implement the output\_schema feature, allowing an agent to attempt to self-correct its JSON output if it fails ActiveModel validation.

### **Epic 3: The "Observable Agent" (Proof-of-Concept UI)**

**Goal:** To provide early visibility by building the backend logging for execution traces and creating a proof-of-concept dashboard to display them.

* **Story 3.1: Basic Execution Monitoring**  
  * Create an Execution model that stores initial input and final output. Build a dashboard index page and a simple show page to display this data, styled with Tailwind and updated via Hotwire.  
* **Story 3.2: Detailed Execution Trace**  
  * Create an ExecutionStep model to log detailed events (thoughts, tool calls). Enhance the execution show page to display this full, real-time chronological trace.

### **Epic 4: The "Secure & Production-Ready Agent"**

**Goal:** To harden the framework for production by implementing the secure context model and providing clear integration points for multi-tenancy.

* **Story 4.1: Research Secure Context & MCP Compatibility**  
  * Analyze best practices for secure context injection and their alignment with the Model Context Protocol (MCP), producing an Architectural Decision Record (ADR).  
* **Story 4.2: Implement Secure Context Passing**  
  * Implement the chosen secure context mechanism, allowing tools to declare their data needs and receive only those values from the context.  
* **Story 4.3: Multi-Tenancy Integration Support**  
  * Update models and jobs to support tenant scoping and provide comprehensive documentation for integrating with gems like acts\_as\_tenant.  
* **Story 4.4: Secure Tool Argument Passing**  
  * Enhance the tool schema to allow marking certain arguments as "context-provided," which are securely injected by the framework and hidden from the LLM.

## **5\. Final Validation**

This Product Requirements Document has passed the pm-checklist validation. No critical deficiencies were found. The plan is approved and ready to proceed to the architectural design phase.

## **6\. Next Steps**

The next step is to hand this document over to the Architect to create the technical blueprint for development based on these requirements.