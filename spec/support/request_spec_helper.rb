module RequestSpecHelper
  def json
    JSON.parse(response.body, object_class: HashWithIndifferentAccess)
  end
end
