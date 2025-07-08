class ApplicationAgent < ApplicationRecord
  include Catalyst::Agentable

  # This model is your default, simple agent type.
  # It has the role, goal, and backstory attributes.
  # You can add shared logic for all "generic" agents here.

  validates :role, presence: true
  validates :goal, presence: true
  validates :backstory, presence: true
end
