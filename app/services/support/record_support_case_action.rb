# Track user activity in controller actions
#
# @see ActivityLogItem
module Support
  class RecordSupportCaseAction
  class UnexpectedActionType < StandardError; end

    ACTION_TYPES = %w[
      opening_case
      adding_interaction
      changing_state
      resolving_case
      closing_case
    ].freeze

    # @param action [String]
    # @param support_case_id [UUID]
    # @param data [Hash]
    #

    def initialize(
      support_case_id:,
      action:,
      data: nil
    )

      @support_case_id = support_case_id
      @action = action
      @data = data
    end

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
