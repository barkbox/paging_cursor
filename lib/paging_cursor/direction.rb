module PagingCursor
  module Direction

    # TODO: *terrible* shouldn't need to cast to array to ensure sort order
    def first(limit = nil)
      limit.nil? ? to_a.first : super
    end

    def last(limit = nil)
      limit.nil? ? to_a.last : super
    end

    def cursor_before
      self.collect(&:id).min
    end

    def cursor_after
      self.collect(&:id).max
    end
  end

  class Array < ::Array
  end

  Array.include Direction
end
