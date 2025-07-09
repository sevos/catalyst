class <%= class_name %> < ApplicationRecord
  include Catalyst::Agentable

<% if parsed_attributes.any? -%>
  # Custom attributes for this agent type
<% parsed_attributes.each do |attr| -%>
  # <%= attr[:name] %> (<%= attr[:type] %>)
<% end -%>

  # Add validations and business logic specific to <%= class_name %>
<% parsed_attributes.each do |attr| -%>
  validates :<%= attr[:name] %>, presence: true
<% end -%>
<% else -%>
  # No custom attributes defined
  # Add validations and business logic specific to <%= class_name %>
<% end -%>
end