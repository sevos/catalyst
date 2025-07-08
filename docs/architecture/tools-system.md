# Tools System Architecture

## Overview

The Catalyst Framework's tools system is built around the **Service Object/Command Pattern**, providing a clean, testable, and extensible way to give agents powerful capabilities.

## Core Tools Architecture

### Base Tool Interface
```ruby
# Base class for all tools
class Catalyst::Tools::Base
  attr_reader :execution_context
  
  def initialize(execution_context: {})
    @execution_context = execution_context
  end
  
  def call(arguments)
    raise NotImplementedError, "Tools must implement #call method"
  end
  
  # Optional: Tool metadata for LLM
  def self.schema
    raise NotImplementedError, "Tools should define their schema"
  end
  
  # Optional: Tool description for LLM
  def self.description
    raise NotImplementedError, "Tools should define their description"
  end
end
```

### Tool Registration System
```ruby
# Tool registry for discovery
module Catalyst
  class ToolRegistry
    @tools = {}
    
    def self.register(name, tool_class)
      @tools[name.to_s] = tool_class
    end
    
    def self.find(name)
      @tools[name.to_s]
    end
    
    def self.all
      @tools.dup
    end
    
    def self.available_for_llm
      @tools.map do |name, tool_class|
        {
          name: name,
          description: tool_class.description,
          schema: tool_class.schema
        }
      end
    end
  end
end

# Auto-registration mixin
module Catalyst
  module Tools
    module Registerable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def register_as(name)
          Catalyst::ToolRegistry.register(name, self)
        end
      end
    end
  end
end
```

## Core Tool Implementations

### Database Query Tool
```ruby
class Catalyst::Tools::DatabaseQuery < Catalyst::Tools::Base
  include Catalyst::Tools::Registerable
  register_as :database_query
  
  def self.description
    "Execute read-only database queries to retrieve information"
  end
  
  def self.schema
    {
      type: "object",
      properties: {
        model: { type: "string", description: "The model class to query" },
        conditions: { type: "object", description: "Query conditions" },
        limit: { type: "integer", description: "Maximum number of results" }
      },
      required: ["model"]
    }
  end
  
  def call(arguments)
    model_class = arguments["model"].constantize
    conditions = arguments["conditions"] || {}
    limit = arguments["limit"] || 10
    
    # Security: Only allow read operations
    raise SecurityError, "Only read operations allowed" unless safe_model?(model_class)
    
    # Apply tenant scoping if available
    scope = apply_tenant_scope(model_class)
    
    # Execute query
    results = scope.where(conditions).limit(limit)
    
    {
      model: arguments["model"],
      results: results.map(&:attributes),
      count: results.size
    }
  end
  
  private
  
  def safe_model?(model_class)
    # Only allow specific models or those with read-only marker
    model_class.respond_to?(:catalyst_readable?) && model_class.catalyst_readable?
  end
  
  def apply_tenant_scope(model_class)
    tenant_id = execution_context[:tenant_id]
    return model_class.all unless tenant_id
    
    if model_class.respond_to?(:for_tenant)
      model_class.for_tenant(tenant_id)
    else
      model_class.all
    end
  end
end
```

### HTTP Request Tool
```ruby
class Catalyst::Tools::HttpRequest < Catalyst::Tools::Base
  include Catalyst::Tools::Registerable
  register_as :http_request
  
  def self.description
    "Make HTTP requests to external APIs"
  end
  
  def self.schema
    {
      type: "object",
      properties: {
        url: { type: "string", description: "The URL to request" },
        method: { type: "string", enum: ["GET", "POST", "PUT", "DELETE"] },
        headers: { type: "object", description: "HTTP headers" },
        body: { type: "string", description: "Request body" }
      },
      required: ["url", "method"]
    }
  end
  
  def call(arguments)
    url = arguments["url"]
    method = arguments["method"].upcase
    headers = arguments["headers"] || {}
    body = arguments["body"]
    
    # Security: URL validation
    raise SecurityError, "Invalid URL" unless valid_url?(url)
    
    # Rate limiting
    check_rate_limit!
    
    # Make request with timeout
    response = make_request(url, method, headers, body)
    
    {
      url: url,
      method: method,
      status: response.code,
      headers: response.headers,
      body: response.body
    }
  end
  
  private
  
  def valid_url?(url)
    uri = URI.parse(url)
    # Allow only HTTP/HTTPS
    return false unless %w[http https].include?(uri.scheme)
    # Block internal networks
    return false if internal_network?(uri.host)
    true
  rescue URI::InvalidURIError
    false
  end
  
  def internal_network?(host)
    # Block common internal networks
    %w[localhost 127.0.0.1 0.0.0.0].include?(host) ||
      host.match?(/^10\./) ||
      host.match?(/^192\.168\./) ||
      host.match?(/^172\.(1[6-9]|2\d|3[01])\./)
  end
  
  def check_rate_limit!
    # Implementation depends on your rate limiting strategy
    # Could use Redis, database, or in-memory store
  end
  
  def make_request(url, method, headers, body)
    # Use a robust HTTP client like Faraday
    conn = Faraday.new do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
    
    conn.public_send(method.downcase, url, body, headers)
  end
end
```

### File System Tool
```ruby
class Catalyst::Tools::FileSystem < Catalyst::Tools::Base
  include Catalyst::Tools::Registerable
  register_as :file_system
  
  def self.description
    "Read files from the file system"
  end
  
  def self.schema
    {
      type: "object",
      properties: {
        action: { type: "string", enum: ["read", "list"] },
        path: { type: "string", description: "File or directory path" }
      },
      required: ["action", "path"]
    }
  end
  
  def call(arguments)
    action = arguments["action"]
    path = arguments["path"]
    
    # Security: Path validation
    raise SecurityError, "Invalid path" unless valid_path?(path)
    
    case action
    when "read"
      read_file(path)
    when "list"
      list_directory(path)
    else
      raise ArgumentError, "Unknown action: #{action}"
    end
  end
  
  private
  
  def valid_path?(path)
    # Resolve path and check if it's within allowed directories
    resolved_path = File.expand_path(path)
    allowed_paths = [
      Rails.root.join("tmp", "catalyst"),
      Rails.root.join("public", "uploads")
    ]
    
    allowed_paths.any? { |allowed| resolved_path.start_with?(allowed.to_s) }
  end
  
  def read_file(path)
    content = File.read(path)
    {
      action: "read",
      path: path,
      content: content,
      size: content.bytesize
    }
  rescue => error
    {
      action: "read",
      path: path,
      error: error.message
    }
  end
  
  def list_directory(path)
    entries = Dir.entries(path).reject { |entry| entry.start_with?(".") }
    {
      action: "list",
      path: path,
      entries: entries
    }
  rescue => error
    {
      action: "list",
      path: path,
      error: error.message
    }
  end
end
```

## Tool Security Framework

### Context-Based Security
```ruby
class Catalyst::Tools::SecurityContext
  def initialize(execution_context)
    @execution_context = execution_context
    @tenant_id = execution_context[:tenant_id]
    @user_id = execution_context[:user_id]
    @permissions = execution_context[:permissions] || []
  end
  
  def can_access_model?(model_class)
    # Check if user has permission to access this model
    @permissions.include?("read_#{model_class.name.underscore}")
  end
  
  def can_make_http_request?(url)
    # Check if URL is in allowed list for this tenant
    allowed_domains = tenant_config[:allowed_domains] || []
    uri = URI.parse(url)
    allowed_domains.any? { |domain| uri.host.end_with?(domain) }
  end
  
  def can_access_path?(path)
    # Check if path is within tenant's allowed directories
    tenant_paths = tenant_config[:allowed_paths] || []
    resolved_path = File.expand_path(path)
    tenant_paths.any? { |allowed| resolved_path.start_with?(allowed) }
  end
  
  private
  
  def tenant_config
    @tenant_config ||= fetch_tenant_config(@tenant_id)
  end
  
  def fetch_tenant_config(tenant_id)
    # Fetch from database, cache, or configuration
    {}
  end
end
```

### Tool Validation
```ruby
module Catalyst
  module Tools
    class Validator
      def self.validate_tool_call(tool_name, arguments, execution_context)
        tool_class = ToolRegistry.find(tool_name)
        return { valid: false, error: "Tool not found" } unless tool_class
        
        # Schema validation
        schema_errors = validate_schema(tool_class.schema, arguments)
        return { valid: false, errors: schema_errors } unless schema_errors.empty?
        
        # Security validation
        security_context = SecurityContext.new(execution_context)
        security_errors = validate_security(tool_class, arguments, security_context)
        return { valid: false, errors: security_errors } unless security_errors.empty?
        
        { valid: true }
      end
      
      private
      
      def self.validate_schema(schema, arguments)
        # JSON Schema validation
        JSON::Validator.fully_validate(schema, arguments)
      end
      
      def self.validate_security(tool_class, arguments, security_context)
        # Tool-specific security validation
        case tool_class.name
        when "Catalyst::Tools::DatabaseQuery"
          validate_database_query_security(arguments, security_context)
        when "Catalyst::Tools::HttpRequest"
          validate_http_request_security(arguments, security_context)
        else
          []
        end
      end
      
      def self.validate_database_query_security(arguments, security_context)
        model_class = arguments["model"].constantize
        unless security_context.can_access_model?(model_class)
          return ["Access denied to model: #{model_class.name}"]
        end
        []
      rescue NameError
        ["Invalid model: #{arguments['model']}"]
      end
      
      def self.validate_http_request_security(arguments, security_context)
        url = arguments["url"]
        unless security_context.can_make_http_request?(url)
          return ["HTTP request not allowed to: #{url}"]
        end
        []
      end
    end
  end
end
```

## Tool Testing Framework

### Base Test Class
```ruby
class Catalyst::Tools::TestCase < ActiveSupport::TestCase
  def setup
    @execution_context = {
      tenant_id: 1,
      user_id: 1,
      permissions: default_permissions
    }
  end
  
  def create_tool(tool_class, context: @execution_context)
    tool_class.new(execution_context: context)
  end
  
  def default_permissions
    %w[read_user read_product]
  end
end
```

### Example Tool Test
```ruby
class Catalyst::Tools::DatabaseQueryTest < Catalyst::Tools::TestCase
  def test_valid_query
    tool = create_tool(Catalyst::Tools::DatabaseQuery)
    
    result = tool.call({
      "model" => "User",
      "conditions" => { "active" => true },
      "limit" => 5
    })
    
    assert result[:results].is_a?(Array)
    assert result[:count] <= 5
  end
  
  def test_security_violation
    tool = create_tool(Catalyst::Tools::DatabaseQuery, 
                      context: { permissions: [] })
    
    assert_raises(SecurityError) do
      tool.call({
        "model" => "User",
        "conditions" => { "active" => true }
      })
    end
  end
end
```

## Tool Performance Monitoring

### Execution Metrics
```ruby
module Catalyst
  module Tools
    module Instrumentation
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def instrument_call
          alias_method :call_without_instrumentation, :call
          
          define_method :call do |arguments|
            start_time = Time.current
            
            begin
              result = call_without_instrumentation(arguments)
              
              # Record success metrics
              record_metrics(
                tool: self.class.name,
                duration: Time.current - start_time,
                success: true
              )
              
              result
            rescue => error
              # Record error metrics
              record_metrics(
                tool: self.class.name,
                duration: Time.current - start_time,
                success: false,
                error: error.class.name
              )
              
              raise
            end
          end
        end
        
        private
        
        def record_metrics(data)
          # Send to monitoring system
          StatsD.timing("catalyst.tool.#{data[:tool]}.duration", data[:duration])
          StatsD.increment("catalyst.tool.#{data[:tool]}.#{data[:success] ? 'success' : 'error'}")
        end
      end
    end
  end
end
```