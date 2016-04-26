class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end

class Tag < ActiveRecord::Base
  self.primary_key = 'name'
end
