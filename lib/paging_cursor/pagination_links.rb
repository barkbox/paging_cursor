module ActiveModel
  class Serializer
    class CollectionSerializer

      def paginated?
        ActiveModelSerializers.config.jsonapi_pagination_links_enabled &&
          object.respond_to?(:current_page) &&
          object.respond_to?(:total_pages) &&
          object.respond_to?(:cursor_before) &&
          object.respond_to?(:cursor_after)
      end
    end
  end
end

module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class PaginationLinks
        MissingSerializationContextError = Class.new(KeyError)
        FIRST_PAGE = 1

        attr_reader :collection, :context

        def initialize(collection, adapter_options)
          @collection = collection
          @adapter_options = adapter_options
          @context = adapter_options.fetch(:serialization_context) do
            fail MissingSerializationContextError, <<-EOF.freeze
 JsonApi::PaginationLinks requires a ActiveModelSerializers::SerializationContext.
 Please pass a ':serialization_context' option or
 override CollectionSerializer#paginated? to return 'false'.
             EOF
          end
        end

        def as_json
          pages_from.each_with_object({}) do |(key, value), hash|
            params = query_parameters.merge(cursor: value).to_query # make sure removing old cursor params

            hash[key] = "#{url(adapter_options)}?#{params}"
            # want http://local.barkshop.com:3333/api/v2/ugc?cursor[after]=&user_id=220083
          end
        end

        protected

        attr_reader :adapter_options

        private

        def pages_from
          p "TOTAL_COUNT: #{collection.total_count}"
          p "PAGE LIMIT: #{collection.cursor_page_limit}"
          p "CURSOR_AFTER: #{collection.cursor_after}"
          p "CURSOR_BEFORE: #{collection.cursor_before}"
          p "PUBLIC_CURRENT_PAGE: #{collection.current_page}"
          return {} if collection.total_pages <= FIRST_PAGE

          {}.tap do |pages|
            pages[:self] = { before: collection.cursor_after }

            unless collection.current_page == FIRST_PAGE # unless on first page
              pages[:first] = { before: nil } # checkout passing nil in url params, doesn't work
              pages[:prev] = { after: collection.cursor_after }
            end

            unless collection.current_page == collection.total_pages # unless on last page
              pages[:next] = { before: collection.cursor_before }
              pages[:last] = { after: nil }
            end
          end
        end

        def url(options)
          @url ||= options.fetch(:links, {}).fetch(:self, nil) || request_url
        end

        def request_url
          @request_url ||= context.request_url
        end

        def query_parameters
          @query_parameters ||= context.query_parameters
        end
      end
    end
  end
end