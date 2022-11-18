module Support
  module Concerns
    module RequestDetailsFormFields
      extend ActiveSupport::Concern

      included do
        option :category_id, optional: true
        option :query_id, optional: true
        option :request_type, Types::ConfirmationField, optional: true
        option :other_category, optional: true
        option :other_query, optional: true
        option :request_text, optional: true

        def self.from_case(support_case)
          new(
            category_id: support_case.category_id,
            query_id: support_case.query_id,
            other_category: support_case.other_category,
            other_query: support_case.other_query,
            request_text: support_case.request_text,
            request_type: support_case.category_id.present?,
          )
        end
      end

      def request_type?
        instance_variable_get :@request_type
      end

      def update!(support_case)
        support_case.update!(
          category_id:,
          query_id:,
          other_category:,
          other_query:,
          request_text:,
        )
      end
    end
  end
end
