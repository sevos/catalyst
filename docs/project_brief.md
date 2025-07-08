# **Project Brief: Catalyst Framework**

## Executive Summary

The project is an open-source, Ruby on Rails framework for orchestrating AI agents, designed as a production-ready and deeply integrated alternative to existing solutions. It aims to solve the problem where current frameworks are often complex to deploy and lack out-of-the-box production features like multi-tenancy and observability, creating a high barrier for Rails developers.

The target market includes all Ruby on Rails developers, offering a gentle learning curve for simple tasks and a powerful, scalable platform for complex AI workflows. The key value proposition is to provide a "golden standard" framework that accelerates development by feeling like a natural extension of Rails. It will achieve this through superior developer experience, built-in observability, production-grade features, and by fostering a vibrant open-source community to drive its evolution, **starting with a powerful and easy-to-use single-agent foundation.**

## Problem Statement

For Ruby on Rails developers, the current landscape for building applications with advanced AI agentic capabilities is a challenging greenfield. The most powerful orchestration frameworks, most notably CrewAI, are Python-exclusive. My research confirms that while excellent Ruby client libraries exist (e.g., `langchainrb`, `ruby_llm`), a mature, native agent *orchestration* framework is missing. This forces developers to either abandon the Rails ecosystem or build brittle, complex integrations.

This technology gap hinders the ability to enhance Rails applications with modern AI, making the ecosystem appear less innovative. Existing solutions like CrewAI, while powerful, operate on an "open-core" model where essential production features (advanced observability, team management, security) are part of a paid enterprise platform. This, combined with high-cost plans, makes them inaccessible for many and substantiates the "open-source bait" concern. Solving this problem is urgent to ensure Rails remains a top-tier choice for modern, intelligent web applications.

## Target Users

**Primary User Segment 1: The Rails Explorer**
* **Profile:** A Ruby on Rails developer proficient with the framework but new to AI/ML concepts.
* **Needs & Pain Points:** Needs a simple, non-intimidating way to add AI features; is frustrated by the complexity of leaving the Rails ecosystem for Python-based tools.
* **Goals:** To quickly add value to their applications using AI without a steep learning curve.

**Primary User Segment 2: The Cross-Functional Pioneer**
* **Profile:** An experienced engineer, possibly with a background in Python/AI, who values robust, observable, and production-ready architecture.
* **Needs & Pain Points:** Needs a framework with the power of existing tools but with superior architectural integrity; is frustrated by the "black box" nature and lack of multi-tenancy in current offerings.
* **Goals:** To build powerful, scalable, and maintainable AI systems within the Rails ecosystem.

**Primary User Segment 3: The Startup & Product Team**
* **Profile:** A small-to-medium-sized team building a SaaS product on Rails, focused on rapid, secure, and scalable feature delivery.
* **Needs & Pain Points:** Needs to quickly deploy multi-tenant AI features without building security and isolation architecture from scratch; is pained by solutions that are not enterprise-ready.
* **Goals:** To accelerate their product roadmap by securely and efficiently integrating sophisticated AI workflows.

## Goals & Success Metrics

**Business Objectives**
* Establish this framework as the definitive open-source AI solution within the Rails community.
* Foster an active, engaged, and collaborative community of users and contributors.
* Generate inbound opportunities for your specialized AI and Rails consulting work.

**User Success Metrics**
* **For the "Rails Explorer":** They can successfully integrate a meaningful AI feature into their application in under an hour.
* **For the "Pioneer" and "Startup Team":** They can build and deploy a secure, scalable AI workflow that would have been prohibitively complex or time-consuming with other tools.

**Key Performance Indicators (KPIs)**
* **Community Adoption:** Achieve **500+ GitHub stars** and demonstrate **consistent week-over-week growth in new version gem downloads** within the first 6 months of the stable 1.0 release.
* **Community Engagement:** Cultivate an active community with at least **20 monthly contributors** (submitting issues, PRs, etc.) within the first year.
* **Developer Success:** Ensure the "time-to-first-successful-agent-run" for a new developer following our tutorial is **under 15 minutes**.

## MVP Scope

**Core Features (Must Have)**
* **Agent Scaffolding:** A Rails generator (`rails g catalyst:agent`) to create an agent class and ERB-powered prompt template.
* **In-Class Tool Definition:** The ability for developers to define tools as private methods directly within the agent class.
* **Asynchronous Task Execution:** Tasks execute via `ActiveJob` by default (`Agent.perform_later(...)`) with a synchronous option available.
* **Structured Output with ActiveModel:** Support for specifying an `ActiveModel` object as an output schema for validation.
* **Built-in Observability:** A basic dashboard providing a detailed execution trace for every task run.

**Out of Scope for MVP**
* Multi-Agent "Teams" and Collaboration.
* Formal "Workflows" that combine agents and deterministic code.
* Advanced, persistent memory systems (the MVP will be stateless between tasks).
* Model Context Protocol (MCP) integration.

**MVP Success Criteria**
The MVP will be a success when a new developer can use the framework to meaningfully enhance a sample application in **under 15 minutes**, demonstrating we have achieved our goals for ease of use and developer experience.

## Post-MVP Vision

**Phase 2 Features (Immediate Next Steps)**
* **Formal Workflows with State Management:** Implement a `Workflow` concept allowing the composition of Agents, Tasks, and deterministic Ruby code, complete with a managed state object for each run.
* **Stateful Memory:** Introduce Agent-level and Team-level short-term memory, as well as persistent, workflow-level long-term memory to support event-driven, long-running processes.

**Long-term Vision**
* Evolve to support collaborative, multi-agent "Teams" with hierarchical and consensual patterns.
* Build out advanced workflow capabilities like external event triggers and cyclical (looping) processes.
* Create a rich tool ecosystem by supporting the Model Context Protocol (MCP).
* Develop an "Agent & Prompt Evaluation Suite" for testing and CI/CD.

## Technical Considerations

* **Target Platform:** A Ruby on Rails Engine, packaged as a gem.
* **Performance Requirements:** Non-blocking architecture, with heavy operations offloaded to background workers via ActiveJob.
* **Technology Preferences:**
    * **Backend:** Ruby on Rails, ActiveJob (Solid Queue), ActiveRecord.
    * **Database:** PostgreSQL to support future `pgvector` integration.
    * **LLMs:** Configurable for both commercial APIs and self-hosted solutions like Ollama.
    * **Dashboard:** Styled with **Tailwind CSS** and powered by the Hotwire stack.
* **Security:** A core architectural principle is the strict separation of application context from LLM context to mitigate prompt-injection risks.

## Constraints & Assumptions

* **Resource Constraint:** The project will be initiated by a solo founder, relying on community contributions for long-term growth, which necessitates a tightly-scoped MVP.
* **Community Assumption:** A high-quality, truly open-source tool will attract an active community of users and contributors.
* **Technical Feasibility Assumption:** Underlying LLM APIs are sufficiently powerful and accessible from Ruby to enable the planned agentic behaviors.

## Risks & Open Questions

* **Key Risks:** Community adoption failing to materialize; creating a product that doesn't perfectly satisfy either beginner or expert users; upstream dependency risks from LLM providers.
* **Open Questions:** How to best design an API that serves both beginner and expert personas; how to best manage the dependency on foundational gems like `ruby_llm`; how to measure real-world adoption beyond vanity metrics.
* **Areas for Further Research:** Community building playbooks; the evolving competitive landscape (in both Ruby and Python); protocols like MCP and the Agent-to-Agent (A2A) standard.

## Appendices

* **Research Summary:** Analysis confirms a market gap for a mature, Rails-native agent orchestration framework. Competitors like CrewAI and LangGraph validate the demand but have architectural and business model drawbacks (paywalled features, lack of multi-tenancy) that we can directly address.
* **Stakeholder Input:** The vision is to create a "golden standard" open-source framework that is production-ready, deeply integrated with Rails, and serves as a flagship project for the ecosystem.
