class ApplicationAgent < ApplicationRecord
  include Catalyst::Agentable
  
  validates :role, presence: true
  validates :goal, presence: true
  validates :backstory, presence: true
end