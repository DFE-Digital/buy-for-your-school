require "rails_helper"

RSpec.describe Energy::CreateRegisterYourInterestZendeskTicketJob, type: :job do
  include ActiveJob::TestHelper

  let(:registration) do
    create(
      :energy_register_your_interest,
      name: "Alex Example",
      email: "alex@example.com",
      phone_number: "01234567890",
      mat_name: "Example MAT",
      ukprn: "12345678",
      switch_gas: true,
      gas_contract_end_date: Date.new(2027, 8, 1),
      switch_electricity: false,
      electricity_contract_end_date: nil,
      status: :submitted,
    )
  end

  let(:zendesk_client) { instance_double(Zendesk::Client, create_ticket: 987_654_321) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(Zendesk::Client).to receive(:new).and_return(zendesk_client)
  end

  around do |example|
    ClimateControl.modify(ZENDESK_ENVIRONMENT: "staging") { example.run }
  end

  it "enqueues on the default queue" do
    expect { described_class.perform_later(registration.id) }
      .to have_enqueued_job(described_class).with(registration.id).on_queue("default")
  end

  it "creates a ticket using the registration answers and saves its id" do
    described_class.perform_now(registration.id)

    expect(zendesk_client).to have_received(:create_ticket).with(
      subject: "Register your interest in Energy for Schools - Example MAT",
      comment: "Register your interest submitted by Alex Example.",
      ticket_form_id: 35_484_269_639_570,
      requester: { name: "Alex Example", email: "alex@example.com" },
      custom_fields: contain_exactly(
        { id: 34_677_379_305_490, value: "1234567890" },
        { id: 34_677_545_715_218, value: "2027-08-01" },
        { id: 35_483_951_884_690, value: "yes_change" },
        { id: 35_484_030_231_314, value: "no_change_elec" },
        { id: 35_484_141_965_458, value: "12345678" },
        { id: 37_977_986_359_570, value: "Example MAT" },
      ),
    )
    expect(registration.reload.zendesk_ticket_id).to eq(987_654_321)
  end

  it "does not create a duplicate ticket when the record already has a Zendesk id" do
    registration.update!(zendesk_ticket_id: 123_456)

    described_class.perform_now(registration.id)

    expect(zendesk_client).not_to have_received(:create_ticket)
  end

  describe "#zendesk_contact_number" do
    subject(:zendesk_contact_number) { described_class.new.send(:zendesk_contact_number, phone_number) }

    context "when the phone number has an international prefix" do
      let(:phone_number) { "+44791469999" }

      it { is_expected.to eq("791469999") }
    end

    context "when the international prefix is followed by a national trunk zero" do
      let(:phone_number) { "+44 (0)7914 699999" }

      it { is_expected.to eq("7914699999") }
    end

    context "when the phone number has parentheses and spaces" do
      let(:phone_number) { "(0181) 8055555" }

      it { is_expected.to eq("1818055555") }
    end

    context "when the phone number has hyphens" do
      let(:phone_number) { "01-811-805555" }

      it { is_expected.to eq("1811805555") }
    end

    context "when there are multiple leading zeroes" do
      let(:phone_number) { "00123456789" }

      it "removes only the first leading zero" do
        expect(zendesk_contact_number).to eq("0123456789")
      end
    end
  end
end
