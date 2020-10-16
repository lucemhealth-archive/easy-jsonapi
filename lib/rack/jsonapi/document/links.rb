The top-level links object MAY contain the following members:
- self: the link that generated the current response document.
- related: a related resource link when the primary data represents 
  a resource relationship.
- pagination links for the primary data. (first, last, prev, next)
  - keys MUST either be omitted or have a nil value to indicate that a link is unavailable

Each member of a links object is a “link”. A link MUST be represented as either:
- a string containing the link’s URL.
- an object (Hash I think) (“link object”) which can contain the following members:
  - href: a string containing the link’s URL.
  - meta: a Meta object
  