# spec/models/energy/task_list_spec.rb
require "rails_helper"

RSpec.describe Energy::TaskList do
  let(:support_establishment_group) { create(:support_establishment_group, :with_address, uid: "123") }
  let(:support_organisation) { create(:support_organisation, urn: 100_253) }
  let(:energy_onboarding_case_organisation) do
    create(:energy_onboarding_case_organisation, onboardable: support_organisation)
  end
  let(:gas_meters) { create(:energy_gas_meter, :with_valid_data, energy_onboarding_case_organisation_id: energy_onboarding_case_organisation.id) }
  let(:electricity_meters) { create(:energy_electricity_meter, :with_valid_data, energy_onboarding_case_organisation_id: energy_onboarding_case_organisation.id) }
  let(:task_list) { described_class.new(energy_onboarding_case_organisation.energy_onboarding_case_id) }

  before do
    energy_onboarding_case_organisation
  end

  describe "#call" do
    context "when switching to gas only" do
      before do
        energy_onboarding_case_organisation.update!(switching_energy_type: :gas)
      end

      it "builds the correct task list with gas tasks" do
        tasks = task_list.call
        expect(tasks.map(&:title)).to eq(%i[
          gas_contract_information
          gas_meters_and_usage
          site_contact_details
          vat_declaration
          billing_preferences
        ])
      end
    end

    context "when switching to electricity only" do
      before do
        energy_onboarding_case_organisation.update!(switching_energy_type: :electricity)
      end

      it "builds the correct task list with electricity tasks" do
        tasks = task_list.call
        expect(tasks.map(&:title)).to eq(%i[
          electric_contract_information
          electric_meters_and_usage
          site_contact_details
          vat_declaration
          billing_preferences
        ])
      end
    end

    context "when switching to both gas and electricity" do
      before do
        energy_onboarding_case_organisation.update!(switching_energy_type: :gas_electricity)
      end

      it "builds the correct task list with both gas and electricity tasks" do
        tasks = task_list.call
        expect(tasks.map(&:title)).to eq(%i[
          gas_contract_information
          electric_contract_information
          gas_meters_and_usage
          electric_meters_and_usage
          site_contact_details
          vat_declaration
          billing_preferences
        ])
      end
    end
  end

  describe "#gas_contract_information" do
    context "when missing gas supplier or contract end date" do
      before do
        energy_onboarding_case_organisation.update!(gas_current_supplier: nil, gas_current_contract_end_date: nil)
      end

      it "returns a not_started task" do
        expect(task_list.send(:gas_contract_information).status).to eq :not_started
      end
    end

    context "when gas supplier and contract end date exist" do
      before do
        energy_onboarding_case_organisation.update!(gas_current_supplier: :british_gas, gas_current_contract_end_date: Date.new(2025, 10, 31))
      end

      it "returns a complete task" do
        expect(task_list.send(:gas_contract_information).status).to eq :complete
      end
    end
  end

  describe "#gas_meters_and_usage" do
    context "when the gas meter type is single and there is one gas meter" do
      before do
        energy_onboarding_case_organisation.update!(gas_single_multi: "single")
        gas_meters
      end

      it "returns a complete task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :complete
      end
    end

    context "when the meter type is single and there are no gas meters" do
      before do
        energy_onboarding_case_organisation.update!(gas_single_multi: "single")
        gas_meters.destroy! if defined?(gas_meters)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :in_progress
      end
    end

    context "when the gas meter type is multi and there are no gas meters" do
      before do
        energy_onboarding_case_organisation.update!(gas_single_multi: "multi")
        gas_meters.destroy! if defined?(gas_meters)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :in_progress
      end
    end

    context "when the gas meter type is multi, there is a gas meter, and the bill consolidated question is answered" do
      before do
        energy_onboarding_case_organisation.update!(gas_single_multi: "multi", gas_bill_consolidation: true)
        gas_meters
      end

      it "returns a complete task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :complete
      end
    end

    context "when there is no gas meter type, gas bill consolidation, or gas meters" do
      before do
        energy_onboarding_case_organisation.update!(gas_single_multi: nil, gas_bill_consolidation: nil)
        gas_meters.destroy! if defined?(gas_meters)
      end

      it "returns a not_started task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :not_started
      end
    end
  end

  describe "#electric_contract_information" do
    context "when missing electric supplier and contract end date" do
      before do
        energy_onboarding_case_organisation.update!(electric_current_supplier: nil, electric_current_contract_end_date: nil)
      end

      it "returns a not_started task" do
        expect(task_list.send(:electric_contract_information).status).to eq :not_started
      end
    end

    context "when electric supplier and contract end date exist" do
      before do
        energy_onboarding_case_organisation.update!(electric_current_supplier: :edf_energy, electric_current_contract_end_date: Date.new(2025, 10, 31))
      end

      it "returns a complete task" do
        expect(task_list.send(:electric_contract_information).status).to eq :complete
      end
    end
  end

  describe "#electric_meters_and_usage" do
    context "when the electric meter type is single and there is one electricity meter" do
      before do
        energy_onboarding_case_organisation.update!(electricity_meter_type: "single")
        electricity_meters
      end

      it "returns a complete task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :complete
      end
    end

    context "when the electricity meter type is single and there are no electricity meters" do
      before do
        energy_onboarding_case_organisation.update!(electricity_meter_type: "single")
        electricity_meters.destroy! if defined?(electricity_meters)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :in_progress
      end
    end

    context "when the electricity meter type is multi and there are no electricity meters" do
      before do
        energy_onboarding_case_organisation.update!(electricity_meter_type: "multi")
        electricity_meters.destroy! if defined?(electricity_meters)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :in_progress
      end
    end

    context "when the electricity meter type is multi, there is a electricity meter, and the bill consolidated question is answered" do
      before do
        energy_onboarding_case_organisation.update!(electricity_meter_type: "multi", is_electric_bill_consolidated: false)
        electricity_meters
      end

      it "returns a complete task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :complete
      end
    end

    context "when there is no electricity meter type, electricity bill consolidation, or electricity meters" do
      before do
        energy_onboarding_case_organisation.update!(electricity_meter_type: nil, is_electric_bill_consolidated: nil)
        electricity_meters.destroy! if defined?(electricity_meters)
      end

      it "returns a not_started task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :not_started
      end
    end
  end

  describe "#site_contact_details" do
    context "when missing site contact mandatory details" do
      before do
        energy_onboarding_case_organisation.update!(site_contact_first_name: nil, site_contact_phone: nil, site_contact_email: nil)
      end

      it "returns a not_started task" do
        expect(task_list.send(:site_contact_details).status).to eq :not_started
      end
    end

    context "when there is a site contact first name, phone, and email" do
      before do
        energy_onboarding_case_organisation.update!(site_contact_first_name: "Jane", site_contact_phone: "0123456789", site_contact_email: "jane@test.com")
      end

      it "returns a complete task" do
        expect(task_list.send(:site_contact_details).status).to eq :complete
      end
    end
  end

  describe "#vat_declaration" do
    context "when vat rate is 20%" do
      before do
        energy_onboarding_case_organisation.update!(vat_rate: 20)
      end

      it "returns a complete task" do
        expect(task_list.send(:vat_declaration).status).to eq :complete
      end
    end

    context "when vat rate is 5%" do
      before do
        energy_onboarding_case_organisation.update!(vat_rate: 5)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:vat_declaration).status).to eq :in_progress
      end
    end

    context "when vat rate is 5%, there is a lower rate percentage, certificate declared, person correct details is true, and contact details are filled in" do
      before do
        energy_onboarding_case_organisation.update!(vat_rate: 5,
                                                    vat_lower_rate_percentage: 8,
                                                    vat_certificate_declared: true,
                                                    vat_person_correct_details: true,
                                                    vat_person_first_name: "Jane",
                                                    vat_person_phone: "0123456789",
                                                    vat_person_address: { "street": "5 Main Street", "locality": "Duke's Place", "postcode": "EC3A 5DE" })
      end

      it "returns a complete task" do
        expect(task_list.send(:vat_declaration).status).to eq :complete
      end
    end

    context "when vat rate is 5%, there is lower rate percentage, certificate declared, person correct details is false, and alt contact details are filled in" do
      before do
        energy_onboarding_case_organisation.update!(vat_rate: 5,
                                                    vat_lower_rate_percentage: 8,
                                                    vat_certificate_declared: true,
                                                    vat_person_correct_details: false,
                                                    vat_alt_person_first_name: "John",
                                                    vat_alt_person_phone: "0123456789",
                                                    vat_alt_person_address: { "street": "5 Main Street", "locality": "Duke's Place", "postcode": "EC3A 5DE" })
      end

      it "returns a complete task" do
        expect(task_list.send(:vat_declaration).status).to eq :complete
      end
    end

    context "when vat rate is not filled in" do
      before do
        energy_onboarding_case_organisation.update!(vat_rate: nil)
      end

      it "returns a not_started task" do
        expect(task_list.send(:vat_declaration).status).to eq :not_started
      end
    end
  end

  describe "#billing_preferences" do
    context "when billing details are empty" do
      before do
        energy_onboarding_case_organisation.update!(billing_payment_method: nil,
                                                    billing_payment_terms: nil,
                                                    billing_invoicing_method: nil,
                                                    billing_invoicing_email: nil,
                                                    billing_invoice_address: nil)
      end

      it "returns a not_started task" do
        expect(task_list.send(:billing_preferences).status).to eq :not_started
      end
    end

    context "when billing invoice method is email and other details are empty" do
      before do
        energy_onboarding_case_organisation.update!(billing_payment_method: nil,
                                                    billing_payment_terms: nil,
                                                    billing_invoicing_method: :email,
                                                    billing_invoicing_email: nil,
                                                    billing_invoice_address: nil)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:billing_preferences).status).to eq :in_progress
      end
    end

    context "when billing invoice method is email and other details including invoicing email are filled in" do
      before do
        energy_onboarding_case_organisation.update!(billing_payment_method: :bacs,
                                                    billing_payment_terms: :days14,
                                                    billing_invoicing_method: :email,
                                                    billing_invoicing_email: "jane@test.com",
                                                    billing_invoice_address: nil)
      end

      it "returns a complete task" do
        expect(task_list.send(:billing_preferences).status).to eq :complete
      end
    end

    context "when billing invoice method is paper and other details except invoicing email are filled in" do
      before do
        energy_onboarding_case_organisation.update!(billing_payment_method: :bacs,
                                                    billing_payment_terms: :days14,
                                                    billing_invoicing_method: :paper,
                                                    billing_invoicing_email: nil,
                                                    billing_invoice_address: nil)
      end

      it "returns a complete task" do
        expect(task_list.send(:billing_preferences).status).to eq :complete
      end
    end

    context "when org is part of a trust and other details except address are filled in" do
      before do
        support_organisation.update!(trust_code: "123")
        energy_onboarding_case_organisation.update!(billing_payment_method: :bacs,
                                                    billing_payment_terms: :days14,
                                                    billing_invoicing_method: :paper,
                                                    billing_invoicing_email: nil,
                                                    billing_invoice_address: nil)
      end

      it "returns an in_progress task" do
        expect(task_list.send(:billing_preferences).status).to eq :in_progress
      end
    end

    context "when org is part of a trust and other details including address are filled in" do
      before do
        support_organisation.update!(trust_code: "123")
        energy_onboarding_case_organisation.update!(billing_payment_method: :bacs,
                                                    billing_payment_terms: :days14,
                                                    billing_invoicing_method: :paper,
                                                    billing_invoicing_email: nil,
                                                    billing_invoice_address: { "street": "5 Main Street", "locality": "Duke's Place", "postcode": "EC3A 5DE" })
      end

      it "returns a complete task" do
        expect(task_list.send(:billing_preferences).status).to eq :complete
      end
    end
  end
end
