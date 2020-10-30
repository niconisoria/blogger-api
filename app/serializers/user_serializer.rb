class UserSerializer
  include JSONAPI::Serializer
  attributes :login, :avatar_url, :slug
end
