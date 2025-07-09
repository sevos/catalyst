# Story 1.1.2: Prompt File Generation for ApplicationAgent - Brownfield Addition

## User Story

As a **developer using Catalyst framework**,  
I want **`rails g catalyst:install` to create prompt files like `rails g catalyst:agent` does**,  
So that **I have consistent prompt file generation across all Catalyst generators**.

## Story Context

**Existing System Integration:**
- Integrates with: Rails generator system and existing `catalyst:agent` generator  
- Technology: Ruby on Rails generators
- Follows pattern: Existing prompt file creation pattern from `catalyst:agent`
- Touch points: Install generator workflow, prompt file template system

## Background

This story addresses a consistency gap identified in Epic 1. The `rails g catalyst:agent` generator creates prompt files, but `rails g catalyst:install` does not, creating an inconsistent developer experience. This should have been implemented as part of Story 1.1.

## Acceptance Criteria

**Functional Requirements:**
1. `rails g catalyst:install` generates prompt files with same structure as `catalyst:agent`
2. Prompt file generation follows existing naming and location conventions
3. Generated prompt files are properly configured for ApplicationAgent context

**Integration Requirements:**
4. Existing `catalyst:agent` generator functionality continues to work unchanged
5. New functionality follows existing prompt file generation pattern
6. Integration with Rails generator system maintains current behavior

**Quality Requirements:**
7. Change is covered by appropriate generator tests
8. Generator documentation is updated to reflect prompt file creation
9. No regression in existing install generator functionality verified

## Technical Notes

- **Integration Approach:** Extend existing install generator to include prompt file creation logic from agent generator
- **Existing Pattern Reference:** Copy/adapt prompt file generation from `catalyst:agent` generator
- **Key Constraints:** Must maintain backward compatibility with existing install generator usage

## Definition of Done

- [ ] Install generator creates prompt files matching agent generator pattern
- [ ] Existing install generator functionality verified unchanged  
- [ ] Existing agent generator functionality regression tested
- [ ] Code follows existing generator patterns and standards
- [ ] Generator tests pass (existing and new)
- [ ] Generator documentation updated

## Risk Assessment

**Primary Risk:** Breaking existing install generator functionality
**Mitigation:** Thorough testing of existing install workflow before/after changes
**Rollback:** Simple git revert of generator changes

## Compatibility Verification

- [ ] No breaking changes to existing install generator API
- [ ] File generation changes are additive only  
- [ ] Generated files follow existing Catalyst patterns
- [ ] Performance impact is negligible

## Story Classification

- **Type:** Bug/Gap Fix
- **Epic:** Epic 1
- **Related Story:** Story 1.1 (where this should have been implemented)
- **Priority:** High (consistency gap in delivered functionality)
- **Effort:** Small (single development session, ~2-4 hours)