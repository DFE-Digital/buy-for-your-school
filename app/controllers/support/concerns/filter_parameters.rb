# frozen_string_literal: true

module Support
  module Concerns
    module FilterParameters
      extend ActiveSupport::Concern

      def filter_params_for(filter_scope, persist: true)
        session.delete(filter_scope) if params.key?(:clear)

        cached_filter = session.fetch(filter_scope, {})
        request_filter = params.fetch(filter_scope, {}).permit(:category, :agent, :state, :tower, :stage, :level, :has_org, :user_submitted, :override, sort: sort_params).to_h.symbolize_keys

        session[filter_scope] = request_filter if request_filter.present? && persist

        request_filter.presence || cached_filter.presence || {}
      end

      def sort_params = %i[ref support_level organisation_name subcategory state agent last_updated received action created_by created value]
    end
  end
end
