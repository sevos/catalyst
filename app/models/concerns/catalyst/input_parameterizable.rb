module Catalyst
  module InputParameterizable
    extend ActiveSupport::Concern

    included do
      # JSON serialization for SQLite compatibility
      serialize :input_params, coder: JSON
    end

    # Helper methods for input parameter management
    def input_parameters
      input_params || {}
    end

    def input_parameters=(params)
      self.input_params = params&.transform_keys(&:to_s)
    end

    # Helper method to get specific input parameter
    def input_parameter(key)
      input_parameters[key.to_s]
    end

    # Helper method to set specific input parameter
    def set_input_parameter(key, value)
      current_params = input_parameters.dup
      current_params[key.to_s] = value
      self.input_parameters = current_params
    end

    # Helper method to merge multiple parameters at once
    def merge_input_parameters(new_params)
      return unless new_params

      self.input_parameters = input_parameters.merge(new_params.transform_keys(&:to_s))
    end

    # Helper method to remove a specific parameter
    def remove_input_parameter(key)
      current_params = input_parameters.dup
      current_params.delete(key.to_s)
      self.input_parameters = current_params
    end

    # Helper method to clear all parameters
    def clear_input_parameters
      self.input_parameters = {}
    end
  end
end