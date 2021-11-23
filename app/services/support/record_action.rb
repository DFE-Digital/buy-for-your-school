require "dry-initializer"

module Support
  # Track support case activity in controller actions
  #
  # @see Support::ActivityLogItem

  class RecordAction
    class UnexpectedActionType < StandardError; end
    extend Dry::Initializer

    ACTION_TYPES = %w[
      open_case
      add_interaction
      change_category
      change_service_level
      change_state
      resolve_case
      close_case
    ].freeze

    # TODO: add RecordAction for change_service_level, change_state and close_case when
    # functionality has been added to the case controllers

    # @!attribute action
    #   @return [String]
    option :action, Types::String

    # @!attribute support_case_id
    #   @return [String]
    option :support_case_id, Types::String

    # @!attribute data
    #   @return [Hash]
    option :data, Types::Hash, default: proc { {} }

    def call
      if invalid_action?
        send_rollbar_warning
        raise UnexpectedActionType
      end

      Support::ActivityLogItem.create!(
        support_case_id: @support_case_id,
        action: @action,
        data: @data,
      )
    end

  private

    def valid_action?
      ACTION_TYPES.include?(@action)
    end

    def invalid_action?
      !valid_action?
    end

    def send_rollbar_warning
      Rollbar.warning(
        "An attempt was made to log a support case action with an invalid type",
        support_case_id: @support_case_id,
        action: @action,
        data: @data,
        allowed_action_types: ACTION_TYPES.join(", "),
      )
    end
  end
end
