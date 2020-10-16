A “relationship object” MUST contain at least one of the following:
- links (obj) containing at least one of the following:
  - self
  - related (provides access to Resource Objs linked in a relationship)
    # If present, a related resource link MUST reference a valid URL, even 
    # if the relationship isn’t currently associated with any target resources. 
    # Additionally, a related resource link MUST NOT change because its 
    # relationship’s content changes.


- data (resource linkage) -- nil, [], ResourceID, or [ResourceID]
- meta (obj)

A relationship object that represents a to-many relationship MAY also
contain pagination links under the links member, as described below. 
Any pagination links in a relationship object MUST paginate the 
relationship data, not the related resources.

WHen creating/updating a resource, If a Relationships obj included, each 
Relationship obj must have a data member. The value of this key represents 
the linkage the new resource is to have.



