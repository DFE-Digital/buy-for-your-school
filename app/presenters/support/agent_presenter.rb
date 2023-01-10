# frozen_string_literal: true

module Support
  class AgentPresenter < BasePresenter
    # @return [String]
    def full_name
      "#{first_name} #{last_name}"
    end

    # @return [false]
    def guest?
      false
    end

    # TODO: use this in auth checks
    # # @return [true]
    # def agent?
    #   true
    # end

    # Include 'full_name' in the JSON representation
    #
    # @see Support::AssignmentsController
    #
    # @return [Hash]
    def as_json(options = {})
      super(options).merge({
        "full_name" => full_name,
      })
    end

    def tower_name
      "#{support_tower&.title || 'No'} #{I18n.t('support.case.list.tower')}"
    end
  end
end
