module ActiveModel
  class Serializer
    class CollectionSerializer

      def paginated?
        ActiveModelSerializers.config.jsonapi_pagination_links_enabled &&
          object.respond_to?(:cursor_page_limit) &&
          object.respond_to?(:total_count)
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
          per_page = collection.cursor_page_limit
          pages_from.each_with_object({}) do |(key, value), hash|
            # params = query_parameters.merge(page: { number: value, size: per_page }).to_query
            # params = query_parameters.merge(cursor: { direction => max_index }).to_query # make sure removing old cursor params
            params = query_parameters.merge(cursor: { value }).to_query # make sure removing old cursor params

            hash[key] = "#{url(adapter_options)}?#{params}"
          end
        end

        protected

        attr_reader :adapter_options

        private

        def pages_from
          return {} if collection.total_pages <= FIRST_PAGE
          # return {} if collection.total_size <= collection.cursor_page_limit

          {}.tap do |pages|
            pages[:self] = collection.current_page
            # pages[:self] = { before: collection.cursor_after }

            unless collection.current_page == FIRST_PAGE # unless on first page
            # unless collection.cursor_after == collection.size # unless on first page
              pages[:first] = FIRST_PAGE
              # pages[:first] = { direction => max_index }
              pages[:prev]  = collection.current_page - FIRST_PAGE
              # pages[:prev] = { direction => max_index }
            end

            unless collection.current_page == collection.total_pages # unless on last page
              pages[:next] = collection.current_page + FIRST_PAGE
              # pages[:next] = { direction => max_index }
              pages[:last] = collection.total_pages
              # pages[:last] = { direction => max_index }
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