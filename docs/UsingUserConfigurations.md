<!--
# @markup markdown
# @title UserConfigurations
-->

# Configuring the Middleware

## Quick Start

To add custom checks to the middleware, modify a Config object and pass it to the Config Manager.

The Config Manager is accessible through a block passed to the middleware upon initialization.

```ruby
use JSONAPI::Middleware do |config_manager|
  # ...
end
```

To add restrictions to ALL requests use the default global config included with the Config Manager:

```ruby
use JSONAPI::Middleware do |config_manager|
  config_manager.global.allow_client_ids = true
end
```

To set up a restrictions for a specific resource type, create and configure a new Config object and add it to the Config Manager:

```ruby
use JSONAPI::Middleware do |config_manager|
  config = JSONAPI::ConfigManager::Config.new
  config.allow_client_ids = true
  config_manager[:person] = config
end
```

## Available Config Options

### Document Checking Customization

To specify required members in a document, create a hash in the structure of the expected JSON document, and list required members as nil. Members that are not required do not have to be listed.

```ruby
config.required_document_members = 
  {
    data: {
      attributes: {
        this_is_required: nil
      }
    },
    meta: nil
  }
```

You can go even further by adding a proc instead of nil to provide a custom way of determining whether a value (and request) is valid.

```ruby
config.required_document_members = 
 {
   data: {
     attributes: {
       this_is_required: proc { |value| ['im_allowed', 'me_too', 'also_me'].include?(value) }
     }
   },
   meta: proc { |value_hash| value_hash.keys?(:count) }
 }
```

To allow for client generated ids, set the method to true.

```ruby
  config.allow_client_ids = true
```

### Header Checking Customization

Specify a list of required headers:

```ruby
  config.required_headers = %w[content-type xxx-authentication]
```

### Query Param Customization

Specify a list of required query params:

```ruby
config.required_query_params =
  {
    fields: { people: nil },
    include: nil,
    custom_param: nil
  } 
```
