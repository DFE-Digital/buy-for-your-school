require "support/frameworks/record_keeper"

RSpec.describe Support::Frameworks::RecordKeeper do
  subject(:record_keeper) { described_class.new }

  let(:saved_keys) do
    %i[
      name
      supplier
      category
      expires_at
    ]
  end

  let(:record) do
    {
      name: "Catering services",
      supplier: "ABC",
      category: "Catering",
      expires_at: "2023-04-15",
    }
  end

  describe "#call" do
    it "persists the framework" do
      expect { record_keeper.call([record]) }.to change { Support::Framework.count }.by 1
      expect(Support::Framework.last.supplier).to eq record[:supplier]
    end

    it "saves data to the fields chosen" do
      record_keeper.call([record])

      saved_keys.each do |key|
        expect(Support::Framework.last.send(key).blank?).to be false
      end
    end
  end
end
