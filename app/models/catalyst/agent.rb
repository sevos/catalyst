module Catalyst
  # Custom exception for template-related errors
  class TemplateNotFoundError < StandardError; end

  class Agent < ApplicationRecord
    self.table_name = "catalyst_agents"

    # Constants for configuration
    DEFAULT_MODEL = "gpt-4.1-nano"
    TEMPLATE_DIRECTORY = "app/ai/prompts"

    # JSON serialization for SQLite compatibility
    serialize :model_params, coder: JSON

    validates :name, presence: true
    validates :max_iterations, presence: true, numericality: { greater_than: 0 }

    belongs_to :agentable, polymorphic: true

    has_many :executions, class_name: "Catalyst::Execution", foreign_key: "agent_id", dependent: :destroy

    # Execute agent with user message and return plain text LLM response
    def execute(user_message)
      validate_user_message!(user_message)

      execution = create_execution_record(user_message)

      begin
        execution.start!

        system_prompt = build_system_prompt
        llm_response = send_to_llm(system_prompt, user_message)

        execution.complete!(llm_response)
        execution.increment_interaction!

        llm_response
      rescue => error
        handle_execution_error(execution, error)
        raise
      end
    end

    private

    def validate_user_message!(user_message)
      raise ArgumentError, "User message cannot be blank" if user_message.blank?
      raise ArgumentError, "User message must be a string" unless user_message.is_a?(String)
      raise ArgumentError, "User message too long (maximum 10,000 characters)" if user_message.length > 10_000
    end

    def handle_execution_error(execution, error)
      # Safely handle the error without risking validation failures
      sanitized_message = sanitize_error_message(error.message)
      execution.update_columns(
        status: "failed",
        error_message: sanitized_message,
        completed_at: Time.current
      )
    end

    def sanitize_error_message(message)
      # Remove potentially sensitive information from error messages
      message.to_s.gsub(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/, "[EMAIL]")
             .gsub(/\b(?:\d{1,3}\.){3}\d{1,3}\b/, "[IP]")
             .gsub(/\b[A-Za-z0-9]{20,}\b/, "[TOKEN]")
             .truncate(500)
    end

    def create_execution_record(user_message)
      executions.create!(
        prompt: user_message.strip,
        input_params: capture_agent_attributes,
        interaction_count: 0
      )
    end

    def capture_agent_attributes
      agent_attrs = attributes.except("id", "created_at", "updated_at")
      agentable_attrs = agentable.attributes.except("id", "created_at", "updated_at")
      agent_attrs.merge(agentable_attrs)
    end

    def build_system_prompt
      template_content = load_prompt_template
      ERB.new(template_content).result(binding_with_agent)
    end

    def load_prompt_template
      template_path = resolve_template_path
      File.read(template_path)
    rescue Errno::ENOENT => e
      raise TemplateNotFoundError, "Template file not found: #{template_path}"
    end

    def resolve_template_path
      template_paths = build_template_inheritance_chain

      template_paths.each do |path|
        return path if File.exist?(path)
      end

      raise TemplateNotFoundError, "No template found for #{agentable.class.name}. Checked: #{template_paths.join(', ')}"
    end

    def build_template_inheritance_chain
      paths = []
      klass = agentable.class

      # Walk up the inheritance chain until we hit ApplicationRecord or nil
      while klass && klass != ApplicationRecord
        template_name = klass.name.underscore
        paths << Rails.root.join(TEMPLATE_DIRECTORY, "#{template_name}.md.erb").to_s
        klass = klass.superclass
      end

      paths
    end

    def binding_with_agent
      @agent = agentable
      binding
    end

    def send_to_llm(system_prompt, user_message)
      chat = RubyLLM.chat(
        model: model || DEFAULT_MODEL,
        **formatted_model_params
      )

      chat.system(system_prompt)
      response = chat.ask(user_message)

      response.to_s
    end

    def formatted_model_params
      return {} unless model_params

      model_params.transform_keys(&:to_sym)
    end
  end
end
