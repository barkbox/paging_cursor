module PagingCursor
  module Direction

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
