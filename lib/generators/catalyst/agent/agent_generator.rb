require "rails/generators"
require "rails/generators/active_record"

module Catalyst
  class AgentGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    desc "Generate a Catalyst agent class with optional custom attributes"

    class_option :custom_attributes, type: :array, default: [],
                 desc: "Custom attributes with types (e.g., campaign_type:string product_id:integer)"

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    def create_agent_class
      if custom_attributes.any?
        create_custom_agent
      else
        create_simple_agent
      end
    end

    def create_prompt_template
      template "agent_prompt.md.erb", "app/ai/prompts/#{file_name}.md.erb"
    end

    private

    def create_simple_agent
      template "simple_agent.rb", "app/ai/#{file_name}.rb"
    end

    def create_custom_agent
      template "custom_agent.rb", "app/models/#{file_name}.rb"
      migration_template "create_custom_agent.rb", "db/migrate/create_#{table_name}.rb"
      update_catalyst_initializer
    end

    def update_catalyst_initializer
      initializer_path = File.join(destination_root, "config/initializers/catalyst.rb")

      return unless File.exist?(initializer_path)

      content = File.read(initializer_path)
      registration_line = "  config.register_agent_type \"#{class_name}\""

      # Skip if already registered
      return if content.include?(registration_line)

      # Find the Catalyst.configure block and add before the end
      if content.match(/^Catalyst\.configure do \|config\|\s*\n(.*?)^end\s*$/m)
        updated_content = content.sub(/^end\s*$/) do |match|
          "#{registration_line}\nend"
        end
        File.write(initializer_path, updated_content)
      else
        say "Warning: Could not find Catalyst.configure block in #{initializer_path}. Please manually add:"
        say "  config.register_agent_type \"#{class_name}\""
      end
    end

    def custom_attributes
      options[:custom_attributes]
    end

    def parsed_attributes
      @parsed_attributes ||= custom_attributes.map do |attr|
        name, type = attr.split(":", 2)

        # Validate attribute name
        unless name =~ /\A[a-z_][a-z0-9_]*\z/
          raise ArgumentError, "Invalid attribute name '#{name}'. Must start with a letter or underscore and contain only letters, numbers, and underscores."
        end

        # Validate and normalize type
        normalized_type = normalize_column_type(type || "string")

        { name: name, type: normalized_type }
      end
    end

    def migration_columns
      parsed_attributes.map do |attr|
        "      t.#{attr[:type]} :#{attr[:name]}"
      end.join("\n")
    end

    def attribute_accessors
      parsed_attributes.map { |attr| ":#{attr[:name]}" }.join(", ")
    end

    def normalize_column_type(type)
      # Common type aliases and validations
      case type.to_s.downcase
      when "str", "varchar"
        "string"
      when "int", "integer"
        "integer"
      when "txt", "longtext"
        "text"
      when "bool", "boolean"
        "boolean"
      when "float", "double"
        "decimal"
      when "datetime", "timestamp"
        "datetime"
      when "date"
        "date"
      when "time"
        "time"
      when "json", "jsonb"
        "json"
      when "decimal", "numeric"
        "decimal"
      when "binary"
        "binary"
      when "string", "text", "integer", "boolean"
        type.to_s
      else
        # For unknown types, validate against Rails column types
        valid_types = %w[string text integer decimal float boolean binary date time datetime timestamp json]
        if valid_types.include?(type.to_s)
          type.to_s
        else
          raise ArgumentError, "Invalid column type '#{type}'. Valid types are: #{valid_types.join(', ')}"
        end
      end
    end
  end
end
