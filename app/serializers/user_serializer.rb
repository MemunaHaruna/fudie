class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :username, :avatar,
              :role, :created_at

  has_many :categories
end
