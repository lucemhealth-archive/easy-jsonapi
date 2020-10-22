GET /articles?include=author&fields[articles]=title,body&fields[people]=name

resource = JSONAPI::Resource.new('articles')
JSONAPI::Item::Param::Include.new('author')
JSONAPI::Fieldset.new(
    [
        JSONAPI::Item::Param::Field.new('articles', [
            JSONAPI::Resource::Field.new('title', nil), 
            JSONAPI::Resource::Field.new('body', nil)
        ])
    , 
        JSONAPI::Item::Param::Field.new('people', [
            JSONAPI::Resource::Field.new('name', nil)
        ])
    ]
  )

# Resource:
# @id   = nil
# @type = 'article'
# @attributes.add() <-- this is where we do the check = JSONAPI::Fieldset.new()
# @host = "https://api.curatess.io"
# req.params.fields == ParamCollection

JSONAPI::Item::Param::Field.new()
resource.attributes.add JSONAPI::Resource::Field.new('title', "my title")
resource.attributes.add JSONAPI::Resource::Field.new('body')
resource.route -> "https://api.curatess.io/articles/123?fields[articles]=title,body" 
resource.contents -> {
    type: articles,
    id: 123,
    attributes: {
        title: "my title",
        body: nil
    }
}

JSONAPI::Resource::Relationship
JSONAPI::Resource::RelationshipCollection

resource = JSONAPI::Resource.new('article')
article_fields = []
article_fields << JSONAPI::Item::Param::Fields.new('articles' , JSONAPI::Resource::Field.new('title', nil))
article_fields << JSONAPI::Item::Param::Fields.new('articles', JSONAPI::Resource::Field.new('body', nil)))
# article_fields << JSONAPI::Item::Param::Field.new('people', JSONAPI::Resource::Field.new('name', nil))) <-- added by joshua
article_fieldset  = JSONAPI::Fieldset.new(resource.type, article_fields)

resource.attributes.add() <- make sure the ::Resource::Field resource 
resource.type matched all of the resources in the array of fields
JSONAPI::Fieldset.new
   @fields = [JSONAPI::Resource:Field, ...]





  #  Questions:
  # - seems like ::Param::Field should be plural bc it refers to a collection of attributes related to a resource object
  # - still don't know what route does tbh
