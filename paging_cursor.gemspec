Gem::Specification.new do |s|
  s.name        = 'paging_cursor'
  s.version     = '0.0.2'
  s.date        = '2016-04-23'
  s.summary     = "ActiveRecord and ActiveController extensions for cursor pagination"
  s.description = "ActiveRecord and ActiveController extensions for cursor pagination"
  s.authors     = ["Becky Segal"]
  s.email       = 'becsegal@gmail.com'
  s.files       = ["lib/paging_cursor.rb"]
  s.license       = 'MIT'

  s.files = Dir['{lib,spec}/**/*', 'README*', 'LICENSE*']

  s.add_development_dependency "rspec"
  s.add_development_dependency "rails", "~> 4.0.0"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
