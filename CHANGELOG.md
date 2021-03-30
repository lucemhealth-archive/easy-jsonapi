# CHANGELOG

## 1.0.5 - 2020-03-30

- Fixed bug in JSONAPI::Exceptions::HeadersExceptions that didn't check for user required headers requirements
- Fixed bug in JSONAPI::Exceptions::QueryParamExceptions that didn't check for user required query param requirements
- Added more tests to the middleware
- Updated Documentation

## 1.0.4 - 2020-03-28

- Fixed JSONAPI::ExceptionsHeadersExceptions bug
- Updated README files

## 1.0.3 - 2020-03-25

- Updated JSONAPI::Exceptions::HeadersExceptions to allow wildcard matching for Accept header

## 1.0.2 - 2020-03-25

- Updated README and fix READE broken links
- Reorganization of README files into docs file.
- Make easy-jsonapi compatible with ruby versions >= 2.5
- Added wrapper around Oj usage so all raised errors are found in the JSONAPI::Exceptions module

## 1.0.0 - 2020-03-24

- This is the first release with a version of 1.0.0. All main features supported, but user configurations can be developed to provide greater adherence to the spec and more developer features.
