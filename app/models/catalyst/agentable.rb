module Catalyst
  module Agentable
    extend ActiveSupport::Concern

    included do
      has_one :catalyst_agent, class_name: "Catalyst::Agent", as: :agentable, dependent: :destroy
      
      delegate :max_iterations, :executions, to: :catalyst_agent, allow_nil: true
    end

    def create_catalyst_agent!(max_iterations: 1)
      create_catalyst_agent(max_iterations: max_iterations)
    end

    def catalyst_agent_or_build
      catalyst_agent || build_catalyst_agent
    end
  end
end