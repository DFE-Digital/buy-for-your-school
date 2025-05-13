# spec/models/energy/task_list_spec.rb
require "rails_helper"

RSpec.describe Energy::TaskList do
  let(:gas_current_supplier) { :british_gas }
  let(:electric_current_supplier) { :edf_energy }

  let(:energy_onboarding_case_organisation) do
    create(:energy_onboarding_case_organisation, :with_energy_details, gas_current_supplier:, electric_current_supplier:)
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

    context "when switching to both gas and electricity only" do
      before do
        energy_onboarding_case_organisation.update!(switching_energy_type: :gas_electricity)
      end

      it "builds the correct task list with both gas and electricity tasks" do
        tasks = task_list.call
        expect(tasks.map(&:title)).to eq(%i[
          gas_contract_information
          gas_meters_and_usage
          electric_contract_information
          electric_meters_and_usage
          site_contact_details
          vat_declaration
          billing_preferences
        ])
      end
    end
  end

  describe "#gas_contract_information" do
    context "when missing supplier or contract end date" do
      let(:gas_current_supplier) { nil }

      it "returns a not_started task" do
        expect(task_list.send(:gas_contract_information).status).to eq :not_started
      end
    end

    context "when supplier and contract end date exist" do
      it "returns a completed task" do
        expect(task_list.send(:gas_contract_information).status).to eq :completed
      end
    end
  end

  describe "#gas_meters_and_usage" do
    context "when there are no gas meters" do
      let(:gas_meters) { [] }

      it "returns a not_started task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :not_started
      end
    end

    context "when there are gas meters" do
      before do
        gas_meters
      end

      it "returns a completed task" do
        expect(task_list.send(:gas_meters_and_usage).status).to eq :completed
      end
    end
  end

  describe "#electric_contract_information" do
    context "when missing contract end date" do
      let(:electric_current_supplier) { nil }

      it "returns a not_started task" do
        expect(task_list.send(:electric_contract_information).status).to eq :not_started
      end
    end

    context "when supplier and contract end date exist" do
      it "returns a completed task" do
        expect(task_list.send(:electric_contract_information).status).to eq :completed
      end
    end
  end

  describe "#electric_meters_and_usage" do
    context "when there are no electricity meters" do
      let(:electricity_meters) { [] }

      it "returns a not_started task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :not_started
      end
    end

    context "when there are electricity meters" do
      before do
        electricity_meters
      end

      it "returns a completed task" do
        expect(task_list.send(:electric_meters_and_usage).status).to eq :completed
      end
    end
  end
end
