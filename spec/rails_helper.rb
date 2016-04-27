ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require 'rails/all'
require 'rspec/rails'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/support/schema.rb'
require File.dirname(__FILE__) + '/support/models.rb'

RSpec.configure do |config|

end
