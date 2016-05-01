require 'active_support/configurable'

module PagingCursor

  def self.configure(&block)
    yield @config ||= PagingCursor::Configuration.new
  end

  def self.config
    @config
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :default_sort_order
    config_accessor :default_page_limit

    def param_name
      config.param_name.respond_to?(:call) ? config.param_name.call : config.param_name
    end

    writer, line = 'def param_name=(value); config.param_name = value; end', __LINE__
    singleton_class.class_eval writer, __FILE__, line
    class_eval writer, __FILE__, line
  end

  configure do |config|
    config.default_sort_order = :asc
    config.default_page_limit = 25
  end
end
