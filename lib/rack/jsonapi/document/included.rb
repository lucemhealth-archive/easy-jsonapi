class Included
  attr_accessor :type, :id, :attribtues, :relationships
  
  def initialize
    @type
    @id
    @attributes
    @relationships
  end
end

All included resources MUST be represented as:
- [Resource objs]

Compound documents require “full linkage”, meaning that every included 
resource MUST be identified by at least one ResourceId object 
in the same document. 
# - These resource identifier objects could either be primary data or 
#   represent resource linkage contained within primary or included resources.
# - he only exception to the full linkage requirement is when relationship 
#   fields that would otherwise contain linkage data are excluded via sparse fieldsets.


A compound document MUST NOT include more than one resource object for each type 
and id pair.




