# frozen_string_literal: true

# Primary data must be 
# - Resource, ResourceId, or nil, for requests that target single resources
# - [Resource], [ResourceId], or [], for requests that target resource collections

# A logical collection of resources MUST be represented as an array, even if it 
# only contains one item or is empty.
