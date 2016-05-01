# Usage

Use `.before`, `.after`, or `.cursor` in ActiveRecord queries to paginate data. A default limit is always applied, or you can override by including `.limit` in your request.

For example, say we have an app with User and Post models.

```
# app/models/user.rb
class User < ActiveRecord::Base
  has_many :posts
end

# app/models/post.rb
class Post < ActiveRecord::Base
  belongs_to :user
end
```

We can retrieve posts starting with the most recent

```
Post.before                 # get the first page of most recent posts with the default limit
Post.before.limit(10)       # get the 10 most recent posts
Post.before(999).limit(10)  # get the 10 most recent posts that were created before the post with id=999
Post.where(user: User.first).before(999)  # get the 10 most recent posts meeting a condition
User.first.posts.before     # get the most recent posts belong to a user
```


Likewise, we can results starting from the oldest records

```
Post.after                  # get the first page of oldest posts with the default limit
Post.after.limit(10)        # get the 10 oldest posts
Post.after(999).limit(10)   # get the 10 oldest posts that are newer than the post with id=999
Post.where(user: User.first).after(999)  # get the 10 oldest posts meeting a condition
User.first.posts.after      # get the oldest posts belong to a user
```

# Sorting results

By default, all results are returned in ascending order. 


To customize, set a config option, class option or per-query option


# Adding pagination metadata to responses

This gem makes no assumptions about how you want to return pagination metadata in your responses. Arrays and results provide the cursor information you need. 

```
result = Post.before(999)
result.length
 => 20
result.cursor_before
 => 990  # the minimum id included in the result
result.cursor_after
 => 998  # the maximum id included in the result
```

TODO
* option for sorting results
* cursor methods on array
* global default for limits
* per-model setting for limits
