# Architecture Overview

## System Overview

The Catalyst Framework is an **Isolated Rails Engine** that provides AI agent orchestration capabilities to any Rails application. The system is designed around three core principles:

1. **Seamless Rails Integration** - Works as a drop-in engine with familiar Rails patterns
2. **Production-Ready by Default** - Async execution, proper queuing, multi-tenancy support
3. **Long-term Extensibility** - Flexible architecture that grows with user needs

## Core Components

### 1. Rails Engine Foundation
- **Isolated Engine** (`--mountable`) for clean separation
- **Namespaced Models** (e.g., `Catalyst::Agent`) prevent conflicts
- **Standard Rails Patterns** for familiarity

### 2. Data Architecture
- **Delegated Types Pattern** for agent flexibility
- **Base Agent Model** (`Catalyst::Agent`) for core functionality
- **Custom Agent Types** (e.g., `ApplicationAgent`) for specific use cases

### 3. Execution Framework
- **ActiveJob Integration** for background processing
- **Asynchronous Execution** to maintain application responsiveness
- **Queue Backend Support** (Solid Queue, Redis, etc.)

### 4. LLM Integration
- **Adapter Pattern** for multiple LLM providers
- **Common Interface** for consistent agent interaction
- **Provider Flexibility** (OpenAI, Gemini, Ollama, etc.)

### 5. Tool System
- **Service Object Pattern** for tool implementations
- **Callable Objects** with single `#call` method
- **Self-contained Tools** for easy testing and maintenance

## Key Design Decisions

- **Database-Centric Design** for state management and observability
- **Multi-Tenant Aware** architecture from day one
- **Security by Design** with proper context isolation
- **Developer Experience First** with Rails conventions