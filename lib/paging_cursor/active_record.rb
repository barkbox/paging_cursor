require 'active_record'

module PagingCursor
  module ActiveRecord

    # TODO: option to set which column is used for pagination
    #  default = :id
    module FinderMethods

      # default order = after
      def cursor(options={})
        options = HashWithIndifferentAccess.new(options)
        result = before(options[:before]) if options.has_key?(:before) || PagingCursor.config.default_sort_order == :desc
        result ||= after(options[:after])
        result.limit(options[:limit] || self.cursor_page_limit)
      end

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
      klass.send(:include, ::PagingCursor::Direction)
    end
  end
end
