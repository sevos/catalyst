module Catalyst
  class Execution < ApplicationRecord
    self.table_name = "catalyst_executions"

    enum :status, {
      pending: "pending",
      running: "running",
      completed: "completed",
      failed: "failed"
    }, default: :pending

    validates :agent, presence: true
    validates :prompt, presence: true

    belongs_to :agent, class_name: "Catalyst::Agent"

    scope :by_status, ->(status) { where(status: status) }
  end
end
