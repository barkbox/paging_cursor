require 'active_record'

module PagingCursor
  module ActiveRecord

    # TODO: option to set which column is used for pagination
    #  default = 
    module FinderMethods
      # default order = after
      def cursor(options={})
        result = before(options[:before]) if options.has_key?(:before)
        result ||= after(options[:after])
        result.limit(options[:limit])
      end

      def before(cursor=nil)
        result = where(cursor ? arel_table[primary_key].lt(cursor) : nil).reorder(arel_table[primary_key].desc)
        result.reverse_cursor_result = true
        result
      end

      def after(cursor=nil)
        where(arel_table[primary_key].gt(cursor || 0)).reorder(arel_table[primary_key].asc)
      end
    end

    module Limits
      attr_accessor :cursor_page_limit

      # TODO: allow setting default at global and model levels
      def initialize *a
        self.cursor_page_limit = 10
        super *a
      end

      def cursor_page_limit
        @cursor_page_limit ||= 10
      end
    end

    module SortedResults
      attr_accessor :reverse_cursor_result

      def initialize *a
        self.reverse_cursor_result = false
        super *a
      end

      def to_a
        ::PagingCursor::Array.new(self.reverse_cursor_result ? super.reverse : super)
      end
    end

    ::ActiveRecord::Base.extend FinderMethods

    klasses = [::ActiveRecord::Relation]
    if defined? ::ActiveRecord::Associations::CollectionProxy
      klasses << ::ActiveRecord::Associations::CollectionProxy
    else
      klasses << ::ActiveRecord::Associations::AssociationCollection
    end

    # support pagination on associations and scopes
    klasses.each do |klass| 
      klass.send(:prepend, SortedResults)
      klass.send(:include, FinderMethods) 
      klass.send(:include, Limits) 
      klass.send(:include, ::PagingCursor::Direction)
    end
  end
end
