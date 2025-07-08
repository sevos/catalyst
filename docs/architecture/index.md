# Catalyst Framework Architecture

## Overview

This directory contains the complete architectural documentation for the Catalyst Framework, a Ruby on Rails Engine designed for orchestrating AI agents in production environments.

## Architecture Documents

### 1. [Architecture Overview](./overview.md)
High-level system overview, core components, and key design decisions.

### 2. [Data Model Architecture](./data-model.md) 
Database schema design, model relationships, and the Delegated Types pattern implementation.

### 3. [Execution Flow Architecture](./execution-flow.md)
Detailed flow of agent execution, ActiveJob integration, and the agentic iteration loop.

### 4. [Tools System Architecture](./tools-system.md)
Tool framework design, security model, and extensibility patterns.

### 5. [Security Model Architecture](./security-model.md)
Multi-tenant security, context isolation, and protection mechanisms.

## Key Architectural Decisions

### 1. Isolated Rails Engine
- **Decision**: Package as `--mountable` Rails Engine
- **Rationale**: Clean separation, prevents naming conflicts, familiar Rails patterns
- **Trade-offs**: Slightly more complex setup vs. better encapsulation

### 2. Delegated Types Pattern
- **Decision**: Use Delegated Types for agent configuration
- **Rationale**: Simple entry point with unlimited extensibility
- **Trade-offs**: Rails 6.1+ requirement vs. clean, flexible architecture

### 3. ActiveJob Foundation
- **Decision**: All executions through ActiveJob
- **Rationale**: Production-ready async processing, queue backend flexibility
- **Trade-offs**: Complexity for simple use cases vs. scalability and reliability

### 4. Database-Centric Design
- **Decision**: Store all execution state in database
- **Rationale**: Observability, debugging, multi-tenancy support
- **Trade-offs**: Database load vs. comprehensive audit trail

### 5. Security by Design
- **Decision**: Multi-layered security from the start
- **Rationale**: Production environments require comprehensive protection
- **Trade-offs**: Initial complexity vs. enterprise-ready security

## Implementation Phases

### Phase 1: Core Foundation (CAT-1.1)
- Basic agent models and execution
- Simple tool framework
- ActiveJob integration
- Basic security model

### Phase 2: Production Features (CAT-1.2+)
- Advanced security features
- Comprehensive monitoring
- Performance optimizations
- Extended tool ecosystem

### Phase 3: Advanced Features (CAT-1.3+)
- Multi-agent coordination
- Custom LLM adapter support
- Advanced debugging tools
- Enterprise integrations

## Development Guidelines

### Code Organization
```
lib/catalyst/
├── models/           # Core data models
├── jobs/             # ActiveJob implementations
├── tools/            # Tool framework and implementations
├── security/         # Security and validation
├── adapters/         # LLM provider adapters
└── monitoring/       # Observability and metrics
```

### Testing Strategy
- **Unit Tests**: Individual components and models
- **Integration Tests**: End-to-end execution flows
- **Security Tests**: Validation of security measures
- **Performance Tests**: Execution speed and resource usage

### Documentation Standards
- **Architecture Documents**: High-level design and decisions
- **API Documentation**: Tool and adapter interfaces
- **Security Documentation**: Security model and best practices
- **Deployment Guides**: Production deployment patterns

## Technology Stack

### Core Dependencies
- **Ruby on Rails**: 7.0+ (Engine framework)
- **ActiveJob**: Async execution (built-in)
- **JSON Schema**: Tool validation
- **Redis**: Rate limiting and caching (optional)

### Optional Dependencies
- **Solid Queue**: Background job processing
- **PostgreSQL**: Production database
- **Prometheus**: Metrics collection
- **Sentry**: Error tracking

## Reference Implementation

The architecture supports the following reference flow:

1. **Agent Creation**: Developer creates custom agent type
2. **Execution Request**: Host application requests agent execution
3. **Job Queuing**: ActiveJob enqueues execution
4. **Secure Execution**: Framework executes with security context
5. **Tool Integration**: Agent uses tools within security boundaries
6. **Result Storage**: Execution results stored in database
7. **Monitoring**: Full observability of execution process

## Next Steps

1. Review individual architecture documents
2. Understand security model requirements
3. Examine tool framework design
4. Plan implementation phases
5. Set up development environment

For implementation details, see the individual architecture documents and the main [Architecture Document](../architecture.md).