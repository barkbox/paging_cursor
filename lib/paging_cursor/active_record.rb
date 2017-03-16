require 'active_record'

module PagingCursor
  module ActiveRecord

    # TODO: option to set which column is used for pagination
    #  default = :id
    module FinderMethods

      # default order = after
      def cursor(options={})
        options = HashWithIndifferentAccess.new(options)
        if options.has_key?(:before) || (!options.has_key?(:after) && PagingCursor.config.default_sort_order == :desc)
          result = before(options[:before])
        else
          result = after(options[:after])
        end
        result.limit(options[:limit] || self.cursor_page_limit)
      end

      # default limit is not applied in before or after, only in cursor, fix README
      def before(cursor=nil)
        result = where(cursor ? arel_table[primary_key].lt(cursor) : nil).reorder(arel_table[primary_key].desc)
        result.sort_order = :desc
        result.cursored = true
        result
      end

      def after(cursor=nil)
        result = where(arel_table[primary_key].gt(cursor || 0)).reorder(arel_table[primary_key].asc)
        result.sort_order = :asc
        result.cursored = true
        result
      end
    end

    module Count

      def total_count(column_name = :all)
        return @total_count if defined?(@total_count) && @total_count

        # Total count can be deduced from paginated records
        # Records are loaded in #before and #after
        if loaded?
          return @total_count = 0 if @records.empty?
          per_page = self.cursor_page_limit
          return @total_count = (current_page - 1) * per_page + @records.length if (@records.length < per_page)
        end

        # If records haven't been paginated just return the count
        # count could include generated columns referenced in #order, so skip #order here
        c = except(:offset, :limit, :order)
        # Remove includes only if they are irrelevant
        c = c.except(:includes) unless references_eager_loaded_tables?
        # .group returns an OrderedHash that responds to #count
        c = c.count(column_name)
        @total_count = if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
          c.count
        else
          c.respond_to?(:count) ? c.count(column_name) : c
        end
      end

      def current_page
        (self.length.to_f / self.cursor_page_limit).ceil
      end

      def total_pages
        (self.total_count.to_f / self.cursor_page_limit).ceil
      end
    end

    module Limit
      attr_accessor :cursor_page_limit

      # TODO: allow setting default at global and model levels
      def initialize *a
        self.default_page_limit = 25
        super *a
      end

      def cursor_page_limit
        @cursor_page_limit ||= PagingCursor.config.default_page_limit
      end
    end

    module SortedResults
      attr_accessor :sort_order, :cursored

      def initialize *a
        self.sort_order = :asc
        self.cursored = false # todo, separate module??
        super *a
      end

      def to_a
        return super unless self.cursored
        r = ::PagingCursor::Array.new(super)
        if self.sort_order != PagingCursor.config.default_sort_order.to_sym
          r.reverse!
        end
        r
      end
    end

    ::ActiveRecord::Base.extend FinderMethods
    ::ActiveRecord::Base.extend Limit
    ::ActiveRecord::Base.extend Count
    # extend ActiveModelSerializers::Adapter::JsonApi by CursorPaginationLinks,
    # monkey patch ActiveModelSerializers::Adapter::JsonApi, overload #pagination_links_for
    # https://github.com/rails-api/active_model_serializers/blob/6c6e45b23f464bd0bb92ae05a4284b72b017be21/lib/active_model_serializers/adapter/json_api.rb

    klasses = [::ActiveRecord::Relation]
    if defined? ::ActiveRecord::Associations::CollectionProxy
      klasses << ::ActiveRecord::Associations::CollectionProxy
    else
      klasses << ::ActiveRecord::Associations::AssociationCollection
    end

    # # support pagination on associations and scopes
    klasses.each do |klass| 
      klass.send(:prepend, SortedResults)
      klass.send(:include, FinderMethods) 
      klass.send(:include, Count)
      klass.send(:include, ::PagingCursor::Direction)
    end
  end
end
