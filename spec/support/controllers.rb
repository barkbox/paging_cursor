# cribbed from https://github.com/davidcelis/api-pagination/blob/master/spec/support/numbers_controller.rb
require 'ostruct'

module Rails
  def self.application
    @application ||= begin
      routes = ActionDispatch::Routing::RouteSet.new
      OpenStruct.new(:routes => routes, :env_config => {})
    end
  end
end

module ControllerExampleGroup
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, ActionController::TestCase::Behavior)

    base.prepend_before do
      @routes = Rails.application.routes
      @controller = described_class.new
    end
  end

  module ClassMethods
    def setup(*methods)
      methods.each do |method|
        if method.to_s =~ /^setup_(fixtures|controller_request_and_response)$/
          prepend_before { send method }
        else
          before         { send method }
        end
      end
    end

    def teardown(*methods)
      methods.each { |method| after { send method } }
    end
  end
end

Rails.application.routes.draw do
  resources :posts, :only => [] do
    get :index_with_cursor, :on => :collection
    get :index_without_cursor, :on => :collection
  end
end

class PostsController < ::ActionController::Base
  include Rails.application.routes.url_helpers

  def index_with_cursor
    data = Post.before(params.slice(:before, :after, :limit))
    render json: data, status: 200
  end

  def index_without_cursor
    data = Post.limit(10)
    render json: data, status: 200
  end
end
