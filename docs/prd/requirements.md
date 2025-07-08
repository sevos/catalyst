# Requirements

## Functional

* **FR1:** The framework must provide a Rails generator (rails g catalyst:agent) to scaffold new Agent classes and their associated ERB prompt templates.  
* **FR2:** The Agent class must allow developers to define its core persona, including role, goal, and backstory.  
* **FR3:** An Agent must support the registration of standalone, reusable Tool objects.  
* **FR4:** The framework must automatically parse a Tool object's interface to make it available to the LLM.  
* **FR5:** Tasks must be executable asynchronously by default, using an ActiveJob backend (perform\_later).  
* **FR6:** The framework must provide a synchronous execution option (perform\_now) for testing and simple scripts.  
* **FR7:** A task must accept an ActiveModel class as an output\_schema to define and validate a structured output.  
* **FR8:** The framework must include a pre-built admin dashboard for observing task executions.  
* **FR9:** The dashboard's execution trace must log the final LLM prompt, the raw response, all tool calls with their inputs/outputs, and the final parsed output.

## Non-Functional

* **NFR1:** The framework must be multi-tenant aware, designed for easy integration with common tenancy gems like acts\_as\_tenant.  
* **NFR2:** A secure context object must be available to Tools without being exposed to the LLM prompt.  
* **NFR3:** The framework must support multiple LLM providers (Commercial APIs, aggregators like OpenRouter, and self-hosted models via Ollama).  
* **NFR4:** The admin dashboard will be styled with Tailwind CSS and use the Hotwire stack.  
* **NFR5:** It must be possible to configure a specific LLM for each individual Agent.  
* **NFR6:** The framework's public APIs, generators, and documentation must be designed with a focus on a high-quality developer experience.  
* **NFR7:** The framework must ship with comprehensive documentation, including a "Getting Started" guide.