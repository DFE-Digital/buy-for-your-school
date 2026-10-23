require "rails_helper"

RSpec.describe Energy::Emails::GasPriceUpdate do
  let(:single_contact) { JSON.parse(Rails.root.join("spec/fixtures/gas_school_single_meter.json").read).fetch("contacts").first }
  let(:multi_contact) { JSON.parse(Rails.root.join("spec/fixtures/gas_school_multi_meter.json").read).fetch("contacts").first }
  let(:client) { instance_double(Notifications::Client) }
  let(:notify_response) { instance_double(Notifications::Client::ResponseNotification) }
  let(:attachment_path) { Rails.root.join("tmp/gas-price-update-spec.pdf").to_s }

  describe "single-meter school" do
    subject(:service) do
      described_class.new(contact: single_contact, school: single_contact.fetch("schools").first, month: "October", client:)
    end

    before do
      File.binwrite(attachment_path, "%PDF test")
      pdf_generator = instance_double(Energy::Documents::GasPriceChangeForecast, call: attachment_path)
      allow(Energy::Documents::GasPriceChangeForecast).to receive(:new)
        .with(school: single_contact.fetch("schools").first, month: "October")
        .and_return(pdf_generator)
    end

    after do
      File.delete(attachment_path) if File.exist?(attachment_path)
    end

    it "selects the single-meter template and builds its personalisation from the JSON" do
      expect(service.template_id).to eq("b663782d-730c-4f79-9e4c-7c287d89aafa")
      expect(service.personalisation).to eq(
        month: "October",
        price_per_kwh: "3.381",
        meter_number: "0000000001",
        monthly_total_amount: "3.504 p/kWh",
        fixed_unit_rate: "0.123 p/kWh",
        "£/day": "£3.113/day",
        sender_name: "DfE Energy for Schools Team",
      )
    end

    it "sends through Notify using the contact email and selected template" do
      allow(client).to receive(:send_email).and_return(notify_response)

      expect(service.call).to eq(notify_response)
      expect(client).to have_received(:send_email).with(hash_including(
                                                          email_address: "single-meter@example.test",
                                                          template_id: "b663782d-730c-4f79-9e4c-7c287d89aafa",
                                                          personalisation: hash_including(month: "October", meter_number: "0000000001"),
                                                        ))
      expect(client).to have_received(:send_email).with(hash_including(
                                                          personalisation: hash_including(
                                                            link_to_file: hash_including(filename: File.basename(attachment_path)),
                                                          ),
                                                        ))
    end
  end

  describe "multi-meter school" do
    subject(:service) do
      described_class.new(contact: multi_contact, school: multi_contact.fetch("schools").first, month: "October", client:)
    end

    before do
      File.binwrite(attachment_path, "%PDF test")
      pdf_generator = instance_double(Energy::Documents::GasPriceChangeForecast, call: attachment_path)
      allow(Energy::Documents::GasPriceChangeForecast).to receive(:new)
        .with(school: multi_contact.fetch("schools").first, month: "October")
        .and_return(pdf_generator)
    end

    after do
      File.delete(attachment_path) if File.exist?(attachment_path)
    end

    it "selects the multi-meter template and builds its personalisation" do
      expect(service.template_id).to eq("1dd97503-b749-4368-9910-024be6f5e6b6")
      expect(service.personalisation).to eq(
        month: "October",
        price_per_kwh: "3.381",
        sender_name: "DfE Energy for Schools Team",
      )
    end

    it "sends the multi-meter template with its generated PDF attached" do
      allow(client).to receive(:send_email).and_return(notify_response)

      expect(service.call).to eq(notify_response)
      expect(Energy::Documents::GasPriceChangeForecast).to have_received(:new).with(
        school: multi_contact.fetch("schools").first,
        month: "October",
      )
      expect(client).to have_received(:send_email).with(hash_including(
                                                          template_id: "1dd97503-b749-4368-9910-024be6f5e6b6",
                                                          personalisation: hash_including(
                                                            link_to_file: hash_including(filename: File.basename(attachment_path)),
                                                          ),
                                                        ))
    end
  end
end
