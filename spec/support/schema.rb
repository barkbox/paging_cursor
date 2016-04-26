ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
  end

  create_table :tags, force: true, id: false do |t|
    t.string :name, primary_key: true
  end
end
