RSpec.describe Exporter do
  describe "#call" do
    let(:buffer) { StringIO.new }

    before do
      allow(File).to receive(:open).with("tmp/exporter_test", "w").and_yield(buffer)
    end

    context "with YAML format" do
      it "saves data to the filesystem in a given format" do
        described_class.new(path: "tmp/exporter_test", format: :yaml).call({
          yaml: [1, 2, 3],
        })

        expect(buffer.string).to eq "---\n:yaml:\n- 1\n- 2\n- 3\n"
      end
    end

    context "with JSON format" do
      it "saves data to the filesystem in a given format" do
        described_class.new(path: "tmp/exporter_test", format: :json).call({
          json: [1, 2, 3],
        })

        expect(buffer.string).to eq "{\"json\":[1,2,3]}"
      end
    end

    context "without a valid path" do
      it "raises an error" do
        expect { described_class.new(format: :json) }.to raise_error KeyError
        expect { described_class.new(format: :json, path: "") }.not_to raise_error
      end
    end

    context "without a valid format" do
      it "raises an error" do
        expect { described_class.new(path: "") }.to raise_error KeyError
        expect { described_class.new(path: "", format: :foo) }.to raise_error Dry::Types::ConstraintError
        expect { described_class.new(path: "", format: :yaml) }.not_to raise_error
      end
    end
  end
end
