# CHANGELOG

## 1.0.11 - 2021-10-8
- Updated dependencies to fix security vulnerability

## 1.0.10 - 2021-09-29
- Updated dependencies to fix security vulnerability

## 1.0.9 - 2021-05-04

- Updated dependencies to fix security vulnerability in rexml

## 1.0.8 - 2021-05-04

- Updated dependencies to fix security vulnerability in rexml

## 1.0.7 - 2021-03-31

- Fixed bug in JSONAPI::Parser::JSONParser that would serialize hashes with symbol key values instead of string

## 1.0.6 - 2021-03-30

- Fixed bug in JSONAPI::Middleware that was not checking for environment variables properly

## 1.0.5 - 2021-03-30

- Fixed bug in JSONAPI::Exceptions::HeadersExceptions that didn't check for user required headers requirements
- Fixed bug in JSONAPI::Exceptions::QueryParamExceptions that didn't check for user required query param requirements
- Added more tests to the middleware
- Updated Documentation

## 1.0.4 - 2021-03-28

- Fixed JSONAPI::ExceptionsHeadersExceptions bug
- Updated README files

## 1.0.3 - 2021-03-25

- Updated JSONAPI::Exceptions::HeadersExceptions to allow wildcard matching for Accept header

## 1.0.2 - 2021-03-25

- Updated README and fix READE broken links
- Reorganization of README files into docs file.
- Make easy-jsonapi compatible with ruby versions >= 2.5
- Added wrapper around Oj usage so all raised errors are found in the JSONAPI::Exceptions module

## 1.0.0 - 2021-03-24

- This is the first release with a version of 1.0.0. All main features supported, but user configurations can be developed to provide greater adherence to the spec and more developer features.
