require "catalyst/version"
require "catalyst/engine"

module Catalyst
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :agent_types

    def initialize
      @agent_types = []
    end

    def register_agent_type(type_name)
      @agent_types << type_name unless @agent_types.include?(type_name)
    end

    def registered_agent_types
      @agent_types
    end
  end
end
