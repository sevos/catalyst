# **Catalyst Framework - Architecture Document**

## **1. Introduction**

This document outlines the overall technical architecture for the **Catalyst Framework**, a Ruby on Rails Engine designed for orchestrating AI agents. It serves as the engineering blueprint for implementing the features and requirements defined in the approved **Product Requirements Document (PRD)**.

The architecture prioritizes a seamless developer experience for Rails developers, production-readiness by default, and long-term extensibility.

### **1.1. Change Log**

| Date | Version | Description | Author |
| :---- | :---- | :---- | :---- |
| 2025-07-08 | 0.1 | Initial high-level architecture draft. | Winston (Architect) |

## **2. High-Level Architecture**

### **2.1. Technical Summary**

The Catalyst Framework is designed as a self-contained **Isolated Rails Engine** that integrates cleanly into any host Rails application. Its core architecture is built around Rails' native **ActiveJob** system, ensuring all time-consuming agentic tasks are executed asynchronously without blocking the main application thread.

The framework's data model uses the powerful **Delegated Types** pattern, providing a simple entry point for new users (ApplicationAgent) while offering unlimited flexibility for advanced, custom agent types. This database-centric design, combined with a secure context model, ensures the framework is multi-tenant aware and production-ready from its first version.

### **2.2. High-Level Diagram**

This diagram illustrates the primary components and data flow when a task is initiated from the host Rails application.

```mermaid
graph TD
    subgraph HostApp["Host Rails Application"]
        A[Controller/Model] -- Creates --> B[ActiveJob]
    end

    subgraph CatalystEngine["Catalyst Engine"]
        C[Catalyst::ExecutionJob] -- Executes --> D[Agent Logic]
        D -- Prompts --> E[LLM Adapter]
        D -- Uses --> F[Tool Object]
        F -- Returns --> D
        D -- Logs --> G[Application DB]
    end

    subgraph Observability["Observability"]
        I[Catalyst Dashboard] -- Reads --> G
    end

    B -- Enqueues --> C
    E -- Sends --> H[External LLM API]
    H -- Responds --> E
    G -- Connects --> I
```

### **2.3. Technology Stack**

The Catalyst Framework leverages a modern, production-ready technology stack that prioritizes developer experience and maintainability:

* **Ruby on Rails 8 mountable engine** - Provides the core framework structure with proper namespace isolation
* **Minitest for testing** - Testing framework with test/dummy app for comprehensive engine testing
* **Frontend Stack:**
  - **Hotwire/Turbo/Stimulus** - Modern Rails frontend approach for reactive UIs without complex JavaScript frameworks
  - **TailwindCSS** - Utility-first CSS framework for rapid UI development

### **2.4. Architectural and Design Patterns**

The framework will be built upon a foundation of standard, robust software design patterns that are familiar to Rails developers.

* **Isolated Rails Engine:** The framework will be packaged as an isolated (--mountable) Rails Engine. This is the most critical decision for ensuring the framework is a good citizen in any host application. It namespaces all core models and controllers (e.g., Catalyst::Agent), preventing naming collisions and ensuring clean separation of concerns.
* **Delegated Types Pattern:** This is the core of our agent configuration architecture. It allows us to have a lean base Catalyst::Agent model while providing unlimited flexibility for developers to create their own custom agent types with specific attributes, all without resorting to messy Single Table Inheritance (STI) workarounds.
* **Background Job Pattern:** All agent executions are performed within ActiveJob wrappers. This is fundamental to our "production-ready by default" principle, ensuring a responsive host application and leveraging the power of queueing backends like Solid Queue.
* **Adapter Pattern:** To support various LLM providers (OpenAI, Gemini, Ollama, etc.), we will use the Adapter pattern. A common internal interface will communicate with specific adapters (Catalyst::LlmAdapters::OpenaiAdapter), making it simple to add new providers without changing the core agent logic.
* **Service Object / Command Pattern:** Our "Callable Object" approach for tools is a direct implementation of the Service Object or Command pattern. Each tool will be a self-contained, testable object with a single public #call method, promoting a clean, decoupled architecture that is easy to manage and test.