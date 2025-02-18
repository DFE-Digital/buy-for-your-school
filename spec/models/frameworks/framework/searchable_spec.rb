require "rails_helper"

describe Frameworks::Framework::Searchable do
  subject(:searchable) { Frameworks::Framework }

  describe "searching" do
    before do
      create(:frameworks_framework, reference: "F3", name: "Playground Equipment")
      create(:frameworks_framework, reference: "F300", name: "Grounds maintenance")
      create(:frameworks_framework, reference: "F3000", name: "ICT equipment")
    end

    describe "by reference" do
      it "finds ONLY the framework with the exact reference" do
        expect(searchable.omnisearch("F3").pluck(:reference)).to eq(%w[F3])
        expect(searchable.omnisearch("F300").pluck(:reference)).to eq(%w[F300])
        expect(searchable.omnisearch("F3000").pluck(:reference)).to eq(%w[F3000])
      end
    end

    describe "by framework name" do
      it "fuzzy searches the whole name case insensitively" do
        expect(searchable.omnisearch("ground").pluck(:name)).to contain_exactly("Playground Equipment", "Grounds maintenance")
        expect(searchable.omnisearch("equip").pluck(:name)).to contain_exactly("Playground Equipment", "ICT equipment")
        expect(searchable.omnisearch("maintenance").pluck(:name)).to contain_exactly("Grounds maintenance")
      end
    end
  end
end
