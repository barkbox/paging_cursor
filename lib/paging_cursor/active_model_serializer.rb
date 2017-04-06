require 'active_model_serializers'

# See https://github.com/rails-api/active_model_serializers/blob/a032201a91cbca407211bca0392ba881eef1f7ba/lib/active_model/serializer/collection_serializer.rb
# for original version
module ActiveModel
  class Serializer
    class CollectionSerializer

      def paginated?
        ActiveModelSerializers.config.jsonapi_pagination_links_enabled &&
        object.respond_to?(:cursor_before) &&
        object.respond_to?(:cursor_after)
      end
    end
  end
end

# See https://github.com/rails-api/active_model_serializers/blob/a032201a91cbca407211bca0392ba881eef1f7ba/lib/active_model_serializers/adapter/json_api/pagination_links.rb
# for the original version
module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class PaginationLinks

        def as_json
          pages_from.each_with_object({}) do |(key, value), hash|
            params = query_parameters.merge(cursor: value)
            params = Rack::Utils.build_nested_query(params)
            hash[key] = "#{url(adapter_options)}?#{params}"
          end
        end

        private

        def pages_from
          {}.tap do |pages|
            return {} if collection.empty?

            pages[:self] = { before: (collection.cursor_after + 1).to_s }
            pages[:first] = { before: nil }
            pages[:prev] = { after: collection.cursor_after.to_s }
            pages[:next] = { before: collection.cursor_before.to_s }
            pages[:last] = { after: nil }
          end
        end
      end
    end
  end
end