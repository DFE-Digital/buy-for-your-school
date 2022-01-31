# frozen_string_literal: true

module Support
  class CreateCase
    # @param agent_id [uuid] the id of agent creating case
    # @param attrs [Hash] hash of attrs to create case from
    def initialize(attrs = {}, agent_id = nil)
      @agent_id = agent_id
      @attrs = attrs
    end

    # @return Support::Case
    def call
      kase = Case.create!(
        agent_id: @agent_id,
        category_id: @attrs[:category_id],
        organisation_id: @attrs[:organisation_id],
        source: @attrs[:source],
        first_name: @attrs[:first_name],
        last_name: @attrs[:last_name],
        email: @attrs[:email],
        phone_number: @attrs[:phone_number],
        request_text: @attrs[:request_text],
        action_required: @attrs.fetch(:action_required, false),
        new_contract: NewContract.create!,
        existing_contract: ExistingContract.create!,
        procurement: Procurement.create!,
      )

      Support::RecordAction.new(
        case_id: kase.id,
        action: "create_case",
      ).call

      kase
    end
  end
end
