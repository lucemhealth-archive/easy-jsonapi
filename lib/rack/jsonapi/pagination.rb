{"include"=>"author", "fields"=>{"articles"=>"title,body,author", "people"=>"name"}, "josh"=>"demoss", }

# class
class Pagination < Param

  def initialize
    super
    keys.each do |key|
      self.send(:define_method, key) do
        # instance_variable_set("@#{key}", self.val[key])
        self.val[key]
      end
      self.send(:define_method, "#{key}=", value) do
        self.val[key] = value
      end
    end
  end

  def keys
    val.keys
  end

end

"page"=>{"offset"=>"1", "limit"=>"1"}

Param.key = "page"
Param.val = {"offset"=>"1", "limit"=>"1"}
p = Pagination.new(in)

Pagination


p.offset
