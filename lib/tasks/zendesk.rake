# frozen_string_literal: true

register_interest_form_id = 35_484_269_639_570

namespace :zendesk do
  desc "Prints the Zendesk ticket forms"
  task ticket_forms: :environment do
    forms = Zendesk::Client.new.ticket_forms
    puts JSON.pretty_generate(forms.map { |form| form.slice("id", "name") })
  end

  desc "Prints the Zendesk ticket form and its supported ticket fields"
  task :ticket_form_fields, [:ticket_form_id] => :environment do |_task, args|
    ticket_form_id = args[:ticket_form_id].presence || abort("Usage: rake zendesk:ticket_form_fields[TICKET_FORM_ID]")

    puts JSON.pretty_generate(Zendesk::Client.new.ticket_form_fields(ticket_form_id:))
  end

  desc "Creates a test Zendesk ticket for the register your interest form"
  task create_test_ticket: :environment do
    require "faker"

    ticket_id = Zendesk::Client.new.create_ticket(
      subject: "Register your interest test - #{Faker::Company.name}",
      comment: "Test ticket created by the Zendesk rake task.",
      ticket_form_id: register_interest_form_id,
      custom_fields: [
        # Contact Number (EfS)
        { id: 34_677_379_305_490, value: Faker::Number.number(digits: 10).to_s },
        # Existing electricity expiry date (EfS)
        { id: 34_677_517_704_082, value: Faker::Date.between(from: Date.current, to: Date.current + 730).iso8601 },
        # Existing Gas expiry date (EfS)
        { id: 34_677_545_715_218, value: Faker::Date.between(from: Date.current, to: Date.current + 730).iso8601 },
        # Change gas supplier (EfS)
        { id: 35_483_951_884_690, value: "yes_change" },
        # Change electricity supplier (EfS)
        { id: 35_484_030_231_314, value: "yes_change_elec" },
        # UKPRN (EfS)
        { id: 35_484_141_965_458, value: Faker::Number.number(digits: 8).to_s },
        # Name of Multi Academy Trust (EfS)
        { id: 37_977_986_359_570, value: Faker::Company.name },
      ],
    )

    puts "Created Zendesk test ticket #{ticket_id}."
  end
end
