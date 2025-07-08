module Catalyst
  class Execution < ApplicationRecord
    self.table_name = "catalyst_executions"

    VALID_STATUSES = %w[pending running completed failed].freeze

    validates :agent, presence: true
    validates :status, presence: true, inclusion: { in: VALID_STATUSES }
    validates :prompt, presence: true

    belongs_to :agent, class_name: "Catalyst::Agent"

    scope :by_status, ->(status) { where(status: status) }
    scope :completed, -> { where(status: "completed") }
    scope :failed, -> { where(status: "failed") }
    scope :pending, -> { where(status: "pending") }
    scope :running, -> { where(status: "running") }
  end
end
