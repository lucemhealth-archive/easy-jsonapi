<!--
# @markup markdown
# @title README
-->

# easy-jsonapi

[![Gem Version](https://badge.fury.io/rb/easy-jsonapi.svg)](https://badge.fury.io/rb/easy-jsonapi)
![](https://ruby-gem-downloads-badge.herokuapp.com/easy-jsonapi?type=total&color=brightgreen)
<!-- [![Build Status](https://secure.travis-ci.org/jsonapi-rb/jsonapi-parser.svg?branch=master)](http://travis-ci.org/jsonapi-rb/parser?branch=master) -->

The gem that makes using [JSON:API](https://jsonapi.org/) ***EASY***!

Ever wanted the benefits of using [JSONAPI](https://jsonapi.org/) without the learning curve of the 34-page [spec](https://jsonapi.org/format/)? Well, now you can! Introducing ***EASY-JSONAPI***, a fully-compliant, lightweight, and intuitive ruby gem that currently provides 3 main use cases:

1. A middleware for filtering out non-compliant HTTP requests
2. A parser to interact with requests in a typical Object-Oriented Fashion, providing convenient and efficient access to headers, query parameters, and document members.
3. A validator to check your serialized responses for [JSONAPI](https://jsonapi.org/) compliance.

With its only gem dependency being [Oj](https://github.com/ohler55/oj), ***easy-jsonapi*** is a lightweight, dependable tool, featuring comprehensive error messages and over 500 unit tests allowing developers to spend less time debugging and more time creating.

As a bonus, flexible user configurations can be added to the middleware providing custom screening on all requests or individual requests depending on the resource type of the endpoint and the given document, header, or query param restrictions from the user.

## Links

- [*Documentation*](tbd)

- [*RubyGems* *repo*](tbd)

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

## Using The Middleware

### Setup

Add the middleware to the stack in order to activate it.

Sintra:

```ruby
# app.rb
use JSONAPI::Middleware
```

Rails:

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

Rack Apps:

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

If `ENV['RACK_ENV']` is set to something other than  `:development`, then the middleware will return the appropriate status code error given the JSON:API clause the headers, query params, or document violates.

### User Configurations

`easy-jsonapi` has a fair amount of flexibility when it comes to user configurations and plenty of room for extending the current user configurations to include more features. To see the currently available configurations see [UsingUserConfigurations](https://github.com/Curatess/easy-jsonapi/UsingUserConfigurations.md) and to propose a new feature create a pull request or ticket on [the github repository](https://github.com/Curatess/easy-jsonapi)

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

This returns a `JSONAPI::Request` object that can be used to access the collection of query params, collection of headers, and the body of the request. To see example usage, see [Using the Request Object](https://github.com/Curatess/easy-jsonapi/UsingTheRequestObject.md).

## Using the Serialized Response Validator

The `JSONAPI::Response` module is responsible for validating whether a serialized response is fully JSONAPI compliant or not.

The following method is provided to validate the response:

```ruby
require 'easy/jsonapi'

#  ... application code

begin
  JSONAPI::Response.validate(headers, body)
rescue => error
  # ... handling
end
```

The `headers` param is a hash of `String => String` or `Symbol => String` of the header keys and values.
The `body` param is either the JSON body or a ruby hash representation of the body.

See the [rubydocs](tbd) for more on the Serialized Response Validator.

## Releases

See [{file:CHANGELOG.md}](https://github.com/Curatess/easy-jsonapi/CHANGELOG.md)

## License

easy-jsonapi is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Curatess/easy-jsonapi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Curatess/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the easy-jsonapi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Curatess/easy-jsonapi/blob/master/CODE_OF_CONDUCT.md).
