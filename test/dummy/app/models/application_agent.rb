class ApplicationAgent < ApplicationRecord
  validates :role, presence: true
  validates :goal, presence: true
  validates :backstory, presence: true

  has_one :catalyst_agent, class_name: "Catalyst::Agent", as: :delegatable, dependent: :destroy
end