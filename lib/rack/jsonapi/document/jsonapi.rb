May include information about its implementation

If present, the value of the jsonapi member MUST be an object (a “jsonapi object”). 

May Contain:
- version (string) indicates the highest level of JSONAPI supported
- meta (obj)

If the version member is not present, clients should assume the server 
implements at least version 1.0 of the specification.