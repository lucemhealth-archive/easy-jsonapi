<!--
# @markup markdown
# @title README
-->

# easy-jsonapi

[![Gem Version](https://badge.fury.io/rb/easy-jsonapi.svg)](https://badge.fury.io/rb/easy-jsonapi)
<!-- [![Build Status](https://secure.travis-ci.org/jsonapi-rb/jsonapi-parser.svg?branch=master)](http://travis-ci.org/jsonapi-rb/parser?branch=master) -->
![](https://ruby-gem-downloads-badge.herokuapp.com/easy-jsonapi?type=total&color=brightgreen)

The gem that makes using [JSON:API](https://jsonapi.org/) ***EASY***!

Ever wanted the benefits of using [JSONAPI](https://jsonapi.org/) without the learning curve of the 34 page [spec](https://jsonapi.org/format/)? Well now you can! Introducing ***EASY-JSONAPI***, a fully-compliant, lightweight, and intuitive ruby gem that currently provides 3 main use cases:

1. A middleware for filtering out non-compliant HTTP requests
2. A parser to interact with requests in typical Object-Oriented Fashion, providing convenient and efficient access to headers, query parameters, and document members.
3. A validator to check your serialized responses for [JSONAPI](https://jsonapi.org/) compliance.

With its only gem dependency being the JSON parser, [Oj](https://github.com/ohler55/oj), ***easy-jsonapi*** is lightweight while featuring comprehensive error messsages and over 500 unit tests to help developers detect errors quickly so they can spend more time creating applications and less time finding bugs.

As a bonus, flexible user configurations can be configured on the middleware to provide additional screening on all requests or particular requests, depending on a requests' resource type and on the given document, header, or query param restrictions provided by the user.

## Resources

- [easy-jsonapi API documentation](tbd)
- [easy-jsonapi on RubyGems](tbd)

## Installation

Add this ine to your applications' Gemfile:

```bash
# Gemfile
gem 'easy-jsonapi'
```

then execute:

```bash
$ bundle
# ...
```

or manually via

```bash
$ gem install easy-jsonapi
# ...
```

## Quick Start

1. Set up the middleware

```ruby
use JSONAPI::Middleware
```

2. Parse the rack environment variable and get access to request components

```ruby
j_req = JSONAPI::Parser.parse_request(env)

j_req.headers.content_type   # => "application/vnd.api+json"
j_req.params.page.offset     # => "1"
j_req.body.data.type         # => "person"
```

3. Validate your serialized JSON:API before returning it to your clients.

```ruby
begin
  JSONAPI::Response.validate(headers, body)
rescue => error
  # ...
end
```

## Releases

See [{file:CHANGELOG.md}](CHANGELOG.md)

## Links

- [*Documentation*](tbd)

- [*RubyGems* *repo*](tbd)

- [*GitHub* *repo*](tbd)

## Exploring The Middleware

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

Bug reports and pull requests are welcome on GitHub at https://github.com/[joshdemoss]/easy-jsonapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the easy-jsonapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).
