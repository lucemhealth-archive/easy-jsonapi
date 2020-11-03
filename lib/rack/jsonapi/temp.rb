# GET /articles?include=author&fields[articles]=title,body&fields[people]=name

# resource = JSONAPI::Resource.new('articles')
# JSONAPI::Request::QueryParamCollection::QueryParam::Include.new('author')
# JSONAPI::Fieldset.new(
#     [
#         JSONAPI::Request::QueryParamCollection::QueryParam::Field.new('articles', [
#             JSONAPI::Resource::Field.new('title', nil), 
#             JSONAPI::Resource::Field.new('body', nil)
#         ])
#     , 
#         JSONAPI::Request::QueryParamCollection::QueryParam::Field.new('people', [
#             JSONAPI::Resource::Field.new('name', nil)
#         ])
#     ]
#   )

# # Resource:
# # @id   = nil
# # @type = 'article'
# # @attributes.add() <-- this is where we do the check = JSONAPI::Fieldset.new()
# # @host = "https://api.curatess.io"
# # req.params.fields == QueryParamCollection

# JSONAPI::Request::QueryParamCollection::QueryParam::Field.new()
# resource.attributes.add JSONAPI::Resource::Field.new('title', "my title")
# resource.attributes.add JSONAPI::Resource::Field.new('body')
# resource.route -> "https://api.curatess.io/articles/123?fields[articles]=title,body" 
# resource.contents -> {
#     type: articles,
#     id: 123,
#     attributes: {
#         title: "my title",
#         body: nil
#     }
# }

# JSONAPI::Resource::Relationships::Relationship
# JSONAPI::Resource::RelationshipCollection

# resource = JSONAPI::Resource.new('article')
# article_fields = []
# article_fields << QueryParam::Fields.new('articles' , JSONAPI::Resource::Field.new('title', nil))
# article_fields << QueryParam::Fields.new('articles', JSONAPI::Resource::Field.new('body', nil)))
# # article_fields << QueryParam::Field.new('people', JSONAPI::Resource::Field.new('name', nil))) <-- added by joshua
# article_fieldset  = JSONAPI::Fieldset.new(resource.type, article_fields)

# resource.attributes.add() <- make sure the ::Resource::Field resource 
# resource.type matched all of the resources in the array of fields
# JSONAPI::Fieldset.new
#    @fields = [JSONAPI::Resource:Field, ...]
