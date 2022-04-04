RSpec.describe Support::Framework, type: :model do
  before { travel_to Time.zone.parse("2022-03-16") }

  after { travel_back }

  it { is_expected.to have_many(:procurements) }

  describe ".active" do
    before do
      create(:support_framework, name: "Active framework 1", expires_at: "2023-01-01")
      create(:support_framework, name: "Active framework 2", expires_at: "2022-09-01")
      create(:support_framework, name: "Expired framework 1", expires_at: "2022-02-01")
      create(:support_framework, name: "Expired framework 2", expires_at: "2021-11-01")
    end

    it "returns frameworks that have not expired" do
      frameworks = described_class.active
      expect(frameworks.size).to eq 2
      expect(frameworks[0].name).to eq "Active framework 1"
      expect(frameworks[1].name).to eq "Active framework 2"
    end
  end

  describe ".omnisearch" do
    before do
      create(:support_framework, name: "Framework 1", category: "Catering", supplier: "ABC", expires_at: "2023-01-01")
      create(:support_framework, name: "Catering services", category: "Catering", supplier: "XYZ", expires_at: "2022-09-01")
      create(:support_framework, name: "Legal services", category: "Legal", supplier: "ABC", expires_at: "2022-04-01")
    end

    it "returns frameworks when searching by supplier" do
      frameworks = described_class.omnisearch("abc")

      expect(frameworks.size).to eq 2
      expect(frameworks[0].name).to eq "Framework 1"
      expect(frameworks[1].name).to eq "Legal services"
    end

    it "returns frameworks when searching by category" do
      frameworks = described_class.omnisearch("cater")

      expect(frameworks.size).to eq 2
      expect(frameworks[0].name).to eq "Framework 1"
      expect(frameworks[1].name).to eq "Catering services"
    end
  end
end
