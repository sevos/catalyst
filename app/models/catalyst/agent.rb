module Catalyst
  class Agent < ApplicationRecord
    self.table_name = "catalyst_agents"
    
    # JSON serialization for SQLite compatibility
    serialize :model_params, coder: JSON

    validates :name, presence: true
    validates :max_iterations, presence: true, numericality: { greater_than: 0 }

    belongs_to :agentable, polymorphic: true

    has_many :executions, class_name: "Catalyst::Execution", foreign_key: "agent_id", dependent: :destroy
  end
end
