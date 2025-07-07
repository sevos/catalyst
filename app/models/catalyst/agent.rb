module Catalyst
  class Agent < ApplicationRecord
    self.table_name = "catalyst_agents"

    validates :delegatable_type, presence: true
    validates :delegatable_id, presence: true
    validates :max_iterations, presence: true, numericality: { greater_than: 0 }

    belongs_to :delegatable, polymorphic: true

    has_many :executions, class_name: "Catalyst::Execution", foreign_key: "agent_id", dependent: :destroy
  end
end