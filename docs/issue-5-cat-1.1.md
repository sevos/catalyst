# CAT-1.1: Create core ActiveRecord models and installation generator

**Issue #5** | **Author:** sevos | **Created:** 2025-07-06T22:36:01Z | **Updated:** 2025-07-07T23:19:46Z | **Labels:** user-story

**GitHub URL:** https://github.com/sevos/catalyst/issues/5

## User Story

As a Framework Developer,  
I want to create a core Catalyst::Agent model using Delegated Types and have the installer generate a default ApplicationAgent type,  
so that the framework has a persistent, idiomatic, and extensible foundation.

### **Acceptance Criteria**

1. A catalyst_agents table is created, designed for the Delegated Types pattern.  
2. A application_agents table is created to hold the configuration for the default, simple agent type.  
3. An executions table is created to track task runs.  
4. A Rails generator (rails g catalyst:install) is created that copies migrations and generates the necessary base models and an initializer in the host application's namespace.

## **1\. Architectural Justification**

### **The Final Architecture: Namespaced Core with Generated Application Models**

This architecture provides the ultimate blend of simplicity and power, perfectly aligning with our goal of creating a framework that feels native to Rails.

* **The Core (in the Gem):** The gem will provide Catalyst::Agent, the base model that contains the delegated_type logic. This keeps the framework's internal machinery cleanly namespaced and encapsulated.  
* **The "Simple Path" (Generated in the App):** The installer will generate an ApplicationAgent model directly into the host app's app/ai directory. This model will have the simple role, goal, and backstory fields. It serves as a perfect, out-of-the-box example and is the primary entry point for developers.  
* **The "Power-User Path" (Created by the Developer):** For advanced use cases, developers can create their own custom delegated types (e.g., MarketingAgent) and register them in an initializer, following the same pattern as the generated ApplicationAgent.

This design is the most robust and idiomatic. It provides a clear separation between framework code and application code, offers a gentle learning curve via the generated ApplicationAgent, and provides unlimited flexibility through custom delegated types.

## **2\. Database Schema Design**

The installer will copy these three migration files to the host application.

### **catalyst_agents Table Migration (Base Table)**

```ruby
# <timestamp>_create_catalyst_agents.rb  
class CreateCatalystAgents < ActiveRecord::Migration[7.1]  
  def change  
    create_table :catalyst_agents do |t|  
      t.string :delegatable_type, null: false  
      t.bigint :delegatable_id, null: false  
        
      t.integer :max_iterations, default: 1, null: false  
      t.bigint :tenant_id, index: true  
        
      t.timestamps  
    end  
      
    add_index :catalyst_agents, [:delegatable_type, :delegatable_id], unique: true, name: 'index_catalyst_agents_on_delegatable'  
  end  
end
```

### **application_agents Table Migration (For the Simple Path)**

```ruby
# <timestamp>_create_application_agents.rb  
class CreateApplicationAgents < ActiveRecord::Migration[7.1]  
  def change  
    create_table :application_agents do |t|  
      t.string :role  
      t.text :goal  
      t.text :backstory  
        
      t.timestamps  
    end  
  end  
end
```

### **executions Table Migration**

```ruby
# <timestamp>_create_catalyst_executions.rb  
class CreateCatalystExecutions < ActiveRecord::Migration[7.1]  
  def change  
    create_table :catalyst_executions do |t|  
      t.references :agent, null: false, foreign_key: { to_table: :catalyst_agents }  
      # ... other columns: status, prompt, result, tenant_id ...  
      t.timestamps  
    end  
  end  
end
```

## **3\. Installation Generator & Generated Files**

The catalyst:install generator will create the migrations and the following files in the host app.

**config/initializers/catalyst.rb (Configuration)**

```ruby
# config/initializers/catalyst.rb  
Catalyst.configure do |config|  
  # Register all agent types here.  
  # The ApplicationAgent is registered by default.  
  config.register_agent_type "ApplicationAgent"  
    
  # Example for a custom agent:  
  # config.register_agent_type "MarketingAgent"  
end
```

**app/ai/application_agent.rb (The "Simple Path" Model)**

```ruby
# app/ai/application_agent.rb  
class ApplicationAgent < ApplicationRecord  
  # This model is your default, simple agent type.  
  # It has the role, goal, and backstory attributes.  
  # You can add shared logic for all "generic" agents here.  
end
```

The gem itself will contain the Catalyst::Agent base model, which will dynamically read the registered types from the initializer. This architecture is now finalized.

## **4\. Testing Strategy**

* **Unit Tests:**  
  * Create model specs for Catalyst::Agent and Catalyst::Execution.  
  * Validate associations, default values, and basic model-level logic.  
* **Integration/Generator Test:**  
  * Create a test that runs the catalyst:install generator within the test/dummy application.  
  * Assert that the migration files are correctly copied into the dummy app's db/migrate directory.

## **5\. Next Steps**

Once this foundational data layer and the installation process are complete and tested, the framework will be ready for **Story CAT-1.2**, which focuses on creating the generator for the agent logic classes (rails g catalyst:agent).