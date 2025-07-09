module Catalyst
  module ModelConfigurable
    extend ActiveSupport::Concern

    included do
      # Serialize model_params as JSON
      serialize :model_params, coder: JSON
    end

    # Helper method to get model parameters with defaults
    def model_parameters
      return {} if model_params.blank?

      model_params.is_a?(String) ? JSON.parse(model_params) : model_params
    rescue JSON::ParserError
      {}
    end

    # Helper method to set model parameters
    def model_parameters=(params)
      if params.present?
        self.model_params = params.is_a?(String) ? params : params.to_json
      else
        self.model_params = nil
      end
    end

    # Helper method to get specific model parameter
    def model_parameter(key)
      model_parameters[key.to_s]
    end

    # Helper method to set specific model parameter
    def set_model_parameter(key, value)
      current_params = model_parameters.dup
      current_params[key.to_s] = value
      self.model_parameters = current_params
    end
  end
end
