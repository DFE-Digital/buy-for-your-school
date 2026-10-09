# frozen_string_literal: true

module Energy
  class CreateRegisterYourInterestZendeskTicketJob < ApplicationJob
    queue_as :default

    def perform(registration_id)
      registration = RegisterYourInterest.find(registration_id)
      return if registration.zendesk_ticket_id.present?

      zendesk_configuration = Zendesk::RegisterYourInterestConfiguration.current
      ticket_id = Zendesk::Client.new.create_ticket(
        subject: "Register your interest in Energy for Schools - #{registration.mat_name}",
        comment: "Register your interest submitted by #{registration.name}.",
        ticket_form_id: zendesk_configuration[:ticket_form_id],
        requester: { name: registration.name, email: registration.email },
        custom_fields: custom_fields(registration, zendesk_configuration[:field_ids]),
      )

      registration.update!(zendesk_ticket_id: ticket_id)
    end

  private

    def custom_fields(registration, field_ids)
      [
        { id: field_ids[:contact_number], value: registration.phone_number },
        { id: field_ids[:electricity_contract_end_date], value: registration.electricity_contract_end_date&.iso8601 },
        { id: field_ids[:gas_contract_end_date], value: registration.gas_contract_end_date&.iso8601 },
        { id: field_ids[:switch_gas], value: registration.switch_gas ? "yes_change" : "no_change" },
        { id: field_ids[:switch_electricity], value: registration.switch_electricity ? "yes_change_elec" : "no_change_elec" },
        { id: field_ids[:ukprn], value: registration.ukprn },
        { id: field_ids[:mat_name], value: registration.mat_name },
      ].reject { |field| field[:value].nil? }
    end
  end
end
