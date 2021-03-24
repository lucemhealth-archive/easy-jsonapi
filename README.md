<!--
# @markup markdown
# @title README
-->

# easy-jsonapi

## A ruby [JSONAPI](http://jsonapi.org) gem that provides 3 main use cases:

- A middleware to intercept and screen http requests that do not conform to the [JSON API specification](http://jsonapi.org)
- A parser to convert requests into objects with intuitive and efficient convenience methods, including header and query parameter collections
- A response validator to validate that serialized responses conform to the [JSON API specification](http://jsonapi.org)

## Status

<!-- [![Gem Version](https://badge.fury.io/rb/jsonapi-parser.svg)](https://badge.fury.io/rb/jsonapi-parser)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/jsonapi-parser.svg?branch=master)](http://travis-ci.org/jsonapi-rb/parser?branch=master)
[![codecov](https://codecov.io/gh/jsonapi-rb/jsonapi-parser/branch/master/graph/badge.svg)](https://codecov.io/gh/jsonapi-rb/parser)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/jsonapi-rb/Lobby) -->

## Resources

- API rubydocs: [jsonapi-rb.org](http://jsonapi-rb.org)

## Installation

Add this ine to your applications' Gemfile:

```ruby
# Gemfile
gem 'easy-jsonapi'
```

then execute:

```ruby
$ bundle
# ...
```

or manually via

```ruby
$ gem install easy-jsonapi
# ...
```

## Using the Middleware

### Setup

#### Sintra

```ruby
# app.rb
use JSONAPI::Middleware
```

#### Rails

Edit `config/environments/development.rb`.

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

#### Rack Apps

```ruby
# config.ru
use JSONAPI::Middleware
```

### Functionality

The easy-jsonapi middleware can opperate in development or production mode.
 
If `ENV['RACK_ENV']` is set to `:development` or not set at all, the middleware will be opperating in development mode.

When the middleware is in development mode it will raise an exception wherever it finds the http request to be non JSONAPI compliant.

The types of exceptions it will raise are:

- `Oj::ParserError` when an included body is not valid JSON
- `JSONAPI::Exceptions::HeaderExceptions::InvalidHeader` when an included header is non-compliant
- `JSONAPI::Exceptions::QueryParamExceptions::InvalidQueryParam` when an included query parameter is non-compliant
- `JSONAPI::Exceptions::DocumentExceptions::InvalidDocument` when the body is included and non-compliant

If `ENV['RACK_ENV']` is set to something other than  `:development`, then the middleware will return a 400 status code indicating a malformed request.

## Using the Request Parser

The request parser works by parsing the rack `env` variable.

With Rails or Sinatra you can access this by using:

```ruby
request.env
```

For rack apps you get env from the call method:

```ruby
def call(env)

  # ...

end
```

To parse:

```ruby
require 'easy/jsonapi'

# ...

jsonapi_req = JSONAPI::Parser.parse_request(env)
```

This returns a `JSONAPI::Request` object that can be used to access the collection of query params, collection of headers, and the body of the request. To see example usage, see [Using the JSONPI::Request Object](tbd).

## Using the Serialized Response Validator

The `JSONAPI::Response` module is responsible for validating whether a serialized response is fully JSONAPI compliant or not.

The following methods are provided to validate the response.

```ruby
require 'easy/jsonapi'

#  ...

JSONAPI::Response.validate(body, headers)

JSONAPI::Response.validate(body)

JSONAPI::Response.validate(headers)
```

The `body` param is either the JSON body or a ruby hash representation of the body.
The `headers` param is a hash of `String => String` of the header keys and values.

See the [rubydocs](tbd) for more on the Serialized Response Validator.

## License

easy-jsonapi is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/easy-jsonapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the easy-jsonapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).
