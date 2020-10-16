May contain any valid json value

Complex data structures involving JSON objects and arrays are allowed as attribute values
- any object that constitutes or is contained in an attribute MUST NOT contain a relationships or 
  links member, as those members are reserved by this specification for future use.

Although has-one foreign keys (e.g. author_id) are often stored internally alongside other 
information to be represented in a resource object, these keys SHOULD NOT appear as attributes.

