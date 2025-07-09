Catalyst.configure do |config|
  # Register all agent types here.
  # The ApplicationAgent is registered by default.
  config.register_agent_type "ApplicationAgent"

  # Example for a custom agent:
  # config.register_agent_type "MarketingAgent"
end
