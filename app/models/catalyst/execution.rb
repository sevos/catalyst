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
    validate :validate_timestamps_consistency

    belongs_to :agent, class_name: "Catalyst::Agent"

    scope :by_status, ->(status) { where(status: status) }

    # Helper method to start execution
    def start!
      update!(status: :running, started_at: Time.current)
    end

    # Helper method to complete execution
    def complete!(result = nil)
      update!(status: :completed, completed_at: Time.current, result: result)
    end

    # Helper method to fail execution
    def fail!(error_message = nil)
      update!(status: :failed, completed_at: Time.current, error_message: error_message)
    end

    # Helper method to check if execution is in progress
    def running?
      status == "running"
    end

    # Helper method to check if execution has finished
    def finished?
      completed? || failed?
    end

    # Helper method to get execution duration
    def duration
      return nil unless started_at && completed_at
      completed_at - started_at
    end

    private

    # Validate that timestamps are logically consistent
    def validate_timestamps_consistency
      return unless started_at && completed_at

      if started_at >= completed_at
        errors.add(:completed_at, "must be after started_at")
      end
    end
  end
end
