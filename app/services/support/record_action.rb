require "dry-initializer"

module Support
  # Track support case activity in controller actions
  #
  # @see Support::ActivityLogItem

  class RecordAction
    class UnexpectedActionType < StandardError; end
    extend Dry::Initializer

    # TODO: add RecordAction for change_service_level, change_state and close_case when
    # functionality has been added to the case controllers

    ACTION_TYPES = %w[
      create_case
      open_case
      add_interaction
      change_category
      change_service_level
      change_state
      resolve_case
      close_case
      case_modified
      first_contact
      change_case_summary
      transfer_case
    ].freeze

    # @!attribute action
    #   @return [String]
    option :action, Types::Strict::String.enum(*ACTION_TYPES)

    # @!attribute case_id
    #   @return [String]
    option :case_id, Types::String

    # @!attribute data
    #   @return [Hash]
    option :data, Types::Hash, default: proc { {} }

    # @return [Support::ActivityLogItem]
    def call
      Support::ActivityLogItem.transaction do
        Support::ActivityLogItem.create!(
          support_case_id: @case_id,
          action: "case_modified",
          data: @data,
        )

        Support::ActivityLogItem.create!(
          support_case_id: @case_id,
          action: @action,
          data: @data,
        )
      end
    end
  end
end
