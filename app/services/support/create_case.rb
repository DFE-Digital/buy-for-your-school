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
        detected_category_id: @attrs[:detected_category_id],
        source: @attrs[:source],
        first_name: @attrs[:first_name],
        last_name: @attrs[:last_name],
        email: @attrs[:email],
        phone_number: @attrs[:phone_number],
        extension_number: @attrs[:extension_number],
        discovery_method: @attrs[:discovery_method],
        discovery_method_other_text: @attrs[:discovery_method_other_text],
        request_text: @attrs[:request_text],
        action_required: @attrs.fetch(:action_required, false),
        procurement_amount: @attrs[:procurement_amount],
        special_requirements: @attrs[:special_requirements],
        new_contract: NewContract.create!,
        existing_contract: ExistingContract.create!,
        procurement: Procurement.create!,
        **organisation_attributes,
        other_category: @attrs[:other_category],
        user_selected_category: @attrs[:user_selected_category],
        other_query: @attrs[:other_query],
        query_id: @attrs[:query_id],
        support_level: @attrs[:support_level] || :L1,
        value: @attrs[:procurement_amount],
        creation_source: @attrs[:creation_source],
        procurement_stage: ProcurementStage.find_by(key: "need"),
        initial_request_text: @attrs[:request_text],
        state: @attrs[:state] || :initial,
      )

      @attrs[:participating_schools].each { |organisation| CaseOrganisation.create!(case: kase, organisation:) } if @attrs[:participating_schools]

      kase.update!(created_by_id: @attrs[:creator].id) if @attrs[:creator]

      Support::RecordAction.new(
        case_id: kase.id,
        action: "create_case",
      ).call

      kase
    end

  private

    def organisation_attributes
      if @attrs.key?(:organisation)
        { organisation: @attrs[:organisation] }
      else
        { organisation_type: @attrs[:organisation_type], organisation_id: @attrs[:organisation_id] }
      end
    end
  end
end
