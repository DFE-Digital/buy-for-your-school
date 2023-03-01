module Support
  module Concerns
    module RequestDetailsFormFieldsSchema
      extend ActiveSupport::Concern

      included do
        rule(:request_type) do
          key.failure(:missing) if value.nil? # can't do blank as false value
        end

        rule(:category_id) do
          key.failure(:missing) if values[:request_type] == true && value.blank?
        end

        rule(:query_id) do
          key.failure(:missing) if values[:request_type] == false && value.blank?
        end

        rule(:other_category) do
          key.failure(:missing) if values[:category_id] == other_category_id && value.blank?
        end

        rule(:other_query) do
          key.failure(:missing) if values[:query_id] == other_query_id && value.blank?
        end
      end

      def other_category_id
        @other_category_id ||= Support::Category.other_category_id
      end

      def other_query_id
        @other_query_id ||= Support::Query.other_query_id
      end
    end
  end
end
