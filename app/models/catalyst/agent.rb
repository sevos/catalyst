module Catalyst
  class Agent < ApplicationRecord
    self.table_name = "catalyst_agents"

    validates :agentable_type, presence: true
    validates :agentable_id, presence: true
    validates :max_iterations, presence: true, numericality: { greater_than: 0 }

    belongs_to :agentable, polymorphic: true

    has_many :executions, class_name: "Catalyst::Execution", foreign_key: "agent_id", dependent: :destroy
  end
end