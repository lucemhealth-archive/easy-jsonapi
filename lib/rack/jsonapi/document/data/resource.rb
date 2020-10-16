# frozen_string_literal: true

# resource object MUST contain at least the following top-level members: 
# - type (string)
#   - value of type must adhere to member name comstraints
# - id (string) (unless post)

#  a resource object MAY contain any of these top-level members:
#  - attributes (obj)
#  - relationships (obj)
#  - links (obj)
#  - meta (obj)

#  Fields should share the same namespace
#  - a resource can not have an attribute and relationship with the same name, nor can it have an attribute or 
#   relationship named type or id.
