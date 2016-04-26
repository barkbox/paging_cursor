module PagingCursor
  module Direction
    def cursor_before
      self.dup.sort.first.try(:id)
    end

    def cursor_after
      self.dup.sort.last.try(:id)
    end
  end

  class Array < ::Array
  end

  Array.include Direction
end
