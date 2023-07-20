# frozen_string_literal: true

module Support
  module Concerns
    module FilterParameters
      extend ActiveSupport::Concern

      included do
        helper_method :cached_filter_params_for
      end

      def filter_params_for(scope, defaults: {}, persist: true)
        clear_filter_cache(scope) if params.key?(:clear)

        cached_params = Hash(cached_filter_params_for(scope))
        submitted_params = Hash(user_submitted_filter_params(scope))

        unless submitted_params.empty? || submitted_params == defaults || persist == false
          set_filter_params_cache(scope, submitted_params)
        end

        defaults.merge(Hash(submitted_params.presence || cached_params.presence))
      end

      def cached_filter_params_for(scope)
        session[scope]
      end

    private

      def user_submitted_filter_params(scope)
        params
          .fetch(scope, {})
          .permit(:category, :agent, :state,
                  :tower, :stage, :level, :has_org,
                  :user_submitted, :override, :search_term,
                  sort: sort_params)
          .to_h
          .symbolize_keys
      end

      def clear_filter_cache(scope)
        session.delete(scope)
      end

      def set_filter_params_cache(scope, new_value)
        session[scope] = new_value
      end

      def sort_params
        %i[
          ref
          support_level
          organisation_name
          subcategory
          state
          agent
          last_updated
          received
          action
          created_by
          created
          value
        ]
      end
    end
  end
end
