require "rails_helper"

describe Support::CaseStatistics do
  subject(:report) { described_class.new }

  describe "top level statistics" do
    before do
      create_list(:support_case, 3, :opened, value: 1.00)
      create_list(:support_case, 2, :on_hold, value: 10.00)
      create(:support_case, :initial, value: 5.50)
    end

    it "has an overview of cases" do
      expect(report.live_cases).to eq(6)
      expect(report.live_value).to eq(28.50)
      expect(report.open_cases).to eq(3)
      expect(report.on_hold_cases).to eq(2)
      expect(report.new_cases).to eq(1)
    end
  end

  describe "breakdown of case stages by tower" do
    subject(:results) { report.breakdown_of_stages_by_tower }

    let(:ict)    { create(:support_category, title: "Laptops", with_tower: "ICT") }
    let(:energy) { create(:support_category, title: "Gas", with_tower: "Energy & Utilities") }

    before do
      # Uncategorised cases
      create(:support_case, :opened, value: 1.00, category: nil)
      create(:support_case, :on_hold, value: 2.00, category: nil)
      create(:support_case, :initial, value: 3.00, category: nil)
      # ICT cases
      create_list(:support_case, 2, :opened, value: 10.00, category: ict)
      create_list(:support_case, 2, :on_hold, value: 2.00, category: ict)
      create_list(:support_case, 2, :initial, value: 1.00, category: ict)
      # Energy cases
      create_list(:support_case, 3, :opened, value: 5.00, category: energy)
      create_list(:support_case, 3, :on_hold, value: 1.00, category: energy)
      create_list(:support_case, 3, :initial, value: 2.00, category: energy)
    end

    it "overview of case states for each tower alphabetically with uncategorised last" do
      expect(results.to_a.length).to eq(3)

      energy_tower_row = results[0]
      expect(energy_tower_row.name).to eq("Energy & Utilities")
      expect(energy_tower_row.live_cases).to eq(9)
      expect(energy_tower_row.open_cases).to eq(3)
      expect(energy_tower_row.on_hold_cases).to eq(3)
      expect(energy_tower_row.live_value).to eq(24.00)

      ict_tower_row = results[1]
      expect(ict_tower_row.name).to eq("ICT")
      expect(ict_tower_row.live_cases).to eq(6)
      expect(ict_tower_row.open_cases).to eq(2)
      expect(ict_tower_row.on_hold_cases).to eq(2)
      expect(ict_tower_row.new_cases).to eq(2)
      expect(ict_tower_row.live_value).to eq(26.00)

      no_tower_row = results[2]
      expect(no_tower_row.name).to eq("No Tower")
      expect(no_tower_row.live_cases).to eq(3)
      expect(no_tower_row.open_cases).to eq(1)
      expect(no_tower_row.on_hold_cases).to eq(1)
      expect(no_tower_row.new_cases).to eq(1)
      expect(no_tower_row.live_value).to eq(6.00)
    end
  end

  describe "breakdown of case levels by tower" do
    subject(:results) { report.breakdown_of_levels_by_tower }

    before do
      ict = create(:support_category, title: "Laptops", with_tower: "ICT")
      energy = create(:support_category, title: "Gas", with_tower: "Energy & Utilities")

      # Uncategorised cases
      create_list(:support_case, 2, support_level: :L1, category: nil)
      create(:support_case, support_level: :L3, category: nil)
      create(:support_case, support_level: :L5, category: nil)
      # ICT cases
      create_list(:support_case, 3, support_level: :L2, category: ict)
      create(:support_case, support_level: :L4, category: ict)
      create_list(:support_case, 2, support_level: :L5, category: ict)
      # Energy cases
      create(:support_case, support_level: :L1, category: energy)
      create_list(:support_case, 2, support_level: :L2, category: energy)
      create_list(:support_case, 3, support_level: :L3, category: energy)
    end

    it "overview of case levels for each tower alphabetically with uncategorised last" do
      energy_tower_row = results[0]
      expect(energy_tower_row.name).to eq("Energy & Utilities")
      expect(energy_tower_row.level_1_cases).to eq(1)
      expect(energy_tower_row.level_2_cases).to eq(2)
      expect(energy_tower_row.level_3_cases).to eq(3)
      expect(energy_tower_row.level_4_cases).to eq(0)
      expect(energy_tower_row.level_5_cases).to eq(0)

      ict_tower_row = results[1]
      expect(ict_tower_row.name).to eq("ICT")
      expect(ict_tower_row.level_1_cases).to eq(0)
      expect(ict_tower_row.level_2_cases).to eq(3)
      expect(ict_tower_row.level_3_cases).to eq(0)
      expect(ict_tower_row.level_4_cases).to eq(1)
      expect(ict_tower_row.level_5_cases).to eq(2)

      no_tower_row = results[2]
      expect(no_tower_row.name).to eq("No Tower")
      expect(no_tower_row.level_1_cases).to eq(2)
      expect(no_tower_row.level_2_cases).to eq(0)
      expect(no_tower_row.level_3_cases).to eq(1)
      expect(no_tower_row.level_4_cases).to eq(0)
      expect(no_tower_row.level_5_cases).to eq(1)
    end
  end
end
