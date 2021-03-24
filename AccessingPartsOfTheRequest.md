<!--
# @markup markdown
# @title AccessingPartsOfTheRequest
-->

# Accessing Different Parts of The Request

```ruby
j_req = JSONAPI::Parser.parse(env)
```

## Quick Access Methods

```ruby
j_req.path # Gives path info
j_req.http_method # GET, POST, PUT, etc
j_req.host # localhost
j_req.port # 8080
j_req.query_string # query string
```

## Accessing the Query Params

```ruby
j_req.params # returns enumerable JSONAPI::Request::QueryParamCollection

q_param = JSONAPI::Request::QueryParamCollection::QueryParam.new 'new_name' 'value'
j_req.params.add(q_param) # add a query param to the collection
j_req.params.get('new_name') # get param
j_req.params.new_name # dynamically get param
j_req.params.remove('new_name') # remove header
j_req.params.to_h # { new_name: ['value'] }

# given ?include=author,comments&filter[author]=name&sort=alpha
j_req.params.includes # includes
j_req.paras.filters # resource filters
j_req.params.sorts # resource ordering
j_req.params.page # page / offset
j_req.params.fields # sparse fieldsets
j_req.params.to_s # include=author,comments&filter[name]=test&new_name=new_val
```

## Accessing the Headers

```ruby
j_req.headers # returns enumerable JSONAPI::HeaderCollection

h = JSONAPI::HeaderCollection::Header.new 'Content-Type', 'text/html'
j_req.headers.add(h)
j_req.headers.get('content-type') # retrieves header
j_req.headers.content_type # dynamically retrieves header
j_req.headers.remove('content-type') # remove header
j_req.headers.to_h # { CONTENT_TYPE: 'text/html' }
j_req.headers.to_s # (JSON compliant) { "CONTENT_TYPE": "text/html" }
```

## Accessing the Request Body

```ruby
j_req.body # returns JSONAPI::Document

j_req.body.data # The JSONAPI data member
j_req.body.meta # The JSONAPI meta member
j_req.body.links # The JSONAPI links member
j_req.body.included # The JSONAPI included member
j_req.body.errors # The JSONAPI errors member
j_req.body.jsonapi # The JSONAPI jsonapi member

j_req.body.to_s # serialized JSONAPI
j_req.body.to_h # ruby hash representation of JSONAPI 

# NOTE: j_req.body.data returns a resoure or an array of resources depending on the request
j_req.body.data # JSONAPI::Document::Resource or [JSONAPI::Document::Resource]
```
