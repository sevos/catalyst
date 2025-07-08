# Epic 2: The "Useful Agent" — Tooling & Outputs

## Epic Goal
Empower agents to perform useful work by calling registered Tool Objects and returning validated, structured data, transforming agents from simple text generators into functional automation tools.

## Epic Description

**Problem Statement:**
Basic agent execution from Epic 1 only provides text responses. To create truly useful agents, they need the ability to interact with external systems through tools and return structured, validated data.

**Solution Overview:**
Implement a robust tool system that allows agents to call external functions and APIs, plus structured output validation to ensure reliable data extraction.

**Value Proposition:**
- Enables agents to perform real work beyond text generation
- Provides structured, validated outputs for integration
- Creates reusable tools that can be shared across agents
- Implements the ReAct pattern for reasoning and acting

## Stories

### 2.1: Reusable Tool Definition & Registration
Create a standard Tool interface requiring `#description`, `#arguments`, and `#call` methods, with agent registration capabilities and automatic schema generation for LLM consumption.

### 2.2: Tool Execution Loop
Enhance the agent iteration loop to parse tool calls from LLM responses, execute the appropriate registered tools, and feed results back into the agent's context for continued reasoning.

### 2.3: Robust Structured Output & Self-Correction
Implement output_schema support using ActiveModel validation, enabling agents to return structured data and automatically self-correct when validation fails.

## Dependencies
- Epic 1 completion (all stories)
- JSON parsing and validation libraries
- ActiveModel for output schema validation
- ReAct pattern implementation

## Success Criteria
- [ ] Developers can create tool classes with standard interface
- [ ] Agents can register and execute multiple tools
- [ ] Tool execution integrates seamlessly with agent iteration loop
- [ ] Agents can return structured, validated outputs
- [ ] Self-correction works when output validation fails
- [ ] Tool calls are secure and properly validated
- [ ] Error handling covers all tool execution scenarios

## Definition of Done
- [ ] All 3 stories completed with acceptance criteria met
- [ ] Tool system works end-to-end with agent execution
- [ ] Structured output validation functions correctly
- [ ] Self-correction improves output quality
- [ ] Tool interface is documented and easy to use
- [ ] Tests cover tool execution and output validation
- [ ] Framework handles tool errors gracefully

## Timeline
**Target: Sprint 3-4**
- Story 2.1: Tool foundation (Sprint 3)
- Stories 2.2-2.3: Tool execution and outputs (Sprint 4)

## Risks & Mitigation
- **Risk:** Tool execution security vulnerabilities
  - **Mitigation:** Implement proper argument validation and sandboxing
- **Risk:** Complex tool call parsing from LLM responses
  - **Mitigation:** Use structured prompts and robust parsing logic
- **Risk:** Self-correction loops causing excessive iterations
  - **Mitigation:** Leverage max_iterations from Epic 1 for control
- **Risk:** Performance impact of tool execution
  - **Mitigation:** Implement timeouts and resource limits

## Notes
This epic transforms agents from simple text generators into functional automation tools. The ReAct pattern (Reasoning + Acting) is central to enabling useful agent behaviors.