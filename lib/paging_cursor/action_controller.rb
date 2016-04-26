require 'action_controller'

module PagingCursor
  module AbstractController
    module Rendering
      def _set_pagination_headers(*data)
        data.first.try(:values).to_a.each do |v|
          response.headers['X-Cursor-Before'] = v.cursor_before if v.respond_to?(:cursor_before)
          response.headers['X-Cursor-After'] = v.cursor_after if v.respond_to?(:cursor_after)
        end
      end

      # Normalizes arguments, options and then delegates render_to_body and
      # sticks the result in <tt>self.response_body</tt>.
      # :api: public
      def render(*args, &block)
        _set_pagination_headers(*args)
      end
    end
  end
  ::ActionController::Base.prepend(AbstractController::Rendering)
end
