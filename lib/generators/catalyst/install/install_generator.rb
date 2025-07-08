require 'rails/generators'
require 'rails/generators/active_record'

module Catalyst
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    desc 'Install Catalyst framework with migrations and base models'

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    def create_migrations
      migration_template "create_catalyst_agents.rb", "db/migrate/create_catalyst_agents.rb"
      migration_template "create_application_agents.rb", "db/migrate/create_application_agents.rb"
      migration_template "create_catalyst_executions.rb", "db/migrate/create_catalyst_executions.rb"
    end

    def create_initializer
      initializer_path = File.join(destination_root, "config/initializers/catalyst.rb")
      template "catalyst_initializer.rb", "config/initializers/catalyst.rb" unless File.exist?(initializer_path)
    end

    def create_ai_directory
      empty_directory "app/ai"
    end

    def create_application_agent
      template "application_agent.rb", "app/ai/application_agent.rb"
    end

    def show_readme
      say ""
      say "=" * 70
      say "Catalyst installation complete!"
      say "=" * 70
      say ""
      say "Next steps:"
      say "1. Run `rails db:migrate` to create the database tables"
      say "2. Your ApplicationAgent model is ready to use in app/ai/application_agent.rb"
      say "3. Check config/initializers/catalyst.rb to configure agent types"
      say ""
      say "Example usage:"
      say "  agent = ApplicationAgent.create!("
      say "    role: 'Assistant',"
      say "    goal: 'Help users with their questions',"
      say "    backstory: 'I am a helpful AI assistant'"
      say "  )"
      say ""
      say "  catalyst_agent = Catalyst::Agent.create!(agentable: agent)"
      say ""
    end
  end
end