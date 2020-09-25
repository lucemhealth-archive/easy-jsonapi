<!--
# @markup markdown
# @title README
-->

# rack-jsonapi

A ruby middleware gem that intercepts http requests, validates [JSON API](http://jsonapi.org), and instantiates standardized jsonapi objects that provide developers fast and convenient access to request attributes.

## Status

<!-- [![Gem Version](https://badge.fury.io/rb/jsonapi-parser.svg)](https://badge.fury.io/rb/jsonapi-parser)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/jsonapi-parser.svg?branch=master)](http://travis-ci.org/jsonapi-rb/parser?branch=master)
[![codecov](https://codecov.io/gh/jsonapi-rb/jsonapi-parser/branch/master/graph/badge.svg)](https://codecov.io/gh/jsonapi-rb/parser)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/jsonapi-rb/Lobby) -->

## Resources

<!-- * Chat: [gitter](http://gitter.im/jsonapi-rb)
* Twitter: [@jsonapirb](http://twitter.com/jsonapirb)
* Docs: [jsonapi-rb.org](http://jsonapi-rb.org) -->

## Installation

```ruby
# Gemfile
gem 'rack-jsonapi'
```

then

```ruby
$ bundle
Using rack-jsonapi
```

or manually via

```ruby
$ gem install rack-jsonapi
Successfully installed rack-jsonapi-version#
```

## Usage

### First, require the gem

```ruby
require 'rack/jsonapi'
```

### Then use the gem as a middleware

#### For Sintra

```ruby
# app.rb
use JSONAPI::Middleware
```

#### For Rails

Editing `config/environments/development.rb`.

```ruby
# config/environments/development.rb

MyApp::Application.configure do
  # Add JSONAPI::Middleware to the bottom of the middleware stack
  config.middleware.insert_after ActionDispatch::Static, JSONAPI::Middleware

  # or, if you're using better_errors:
  config.middleware.insert_before Rack::Lock, JSONAPI::Middleware

  # ...
end
```

#### For Rack Apps

```ruby
# config.ru
use JSONAPI::Middleware
```

### Then, use your new instance variable

With the gem required and added as a middleware, your rack, sinatra, or rails application will have available a new instance variable: `@jsonapi_request`.

`@jsonapi_request` references a JSONAPI::Request object and through this object, all other parts of the request can be accessed as well.

Use this object to quickly access parts of the jsonapi conforming request.

```ruby
@jsonapi_request.instance_variables
# [:@path, :@protocol, :@host, :@port, :@params, :@pagination, :@field_sets, :@headers, :@document]

@jsonapi_request.headers.get(:content_type)
# "application/vnd.api+json"

@jsonapi_request.params.view_all
# params:
#   include = authors, comments
#   sort = alpha
#   filter = usa
```

See the Api Documentation for all included methods:

## License

rack-jsonapi is released under the [MIT License](http://www.opensource.org/licenses/MIT).

<!-- ## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-jsonapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rack-jsonapi/blob/master/CODE_OF_CONDUCT.md). -->

<!-- ## Code of Conduct

Everyone interacting in the rack-jsonapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-jsonapi/blob/master/CODE_OF_CONDUCT.md). -->
