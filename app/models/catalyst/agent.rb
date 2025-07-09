module Catalyst
  class Agent < ApplicationRecord
    include Catalyst::ModelConfigurable

    self.table_name = "catalyst_agents"

    validates :name, presence: true
    validates :max_iterations, presence: true, numericality: { greater_than: 0 }

    belongs_to :agentable, polymorphic: true

    has_many :executions, class_name: "Catalyst::Execution", foreign_key: "agent_id", dependent: :destroy
  end
end
