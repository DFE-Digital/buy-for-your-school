RSpec.describe GetStepsFromTask do
  subject(:service) { described_class.new(task:) }

  let(:task) do
    # TODO: shorten "contentful_fixture_filename" param
    fake_contentful_task(contentful_fixture_filename: "tasks/#{fixture}.json")
  end

  before do
    stub_contentful_steps(tasks: [task])
  end

  describe "#call" do
    let(:fixture) { "checkboxes-task" }

    it "returns the list of entry objects referenced by the step list" do
      result = service.call
      expect(result).to be_a Array
      expect(result.first.id).to eq "checkboxes-question"
    end

    context "when the same entry is found twice" do
      let(:fixture) { "repeat-entries-task" }

      it "returns an error message" do
        expect { service.call }.to raise_error GetStepsFromTask::RepeatEntryDetected, "radio-question"
      end
    end
  end
end
