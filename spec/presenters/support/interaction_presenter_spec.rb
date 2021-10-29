RSpec.describe Support::InteractionPresenter do
  subject(:presenter) { described_class.new(interaction) }

  let(:interaction) { OpenStruct.new(note: "\n foo \n") }
  let(:event_types) { { note: 0, phone_call: 1, email_from_school: 2, email_to_school: 3, support_request: 4 } }

  describe "#note" do
    it "strips new lines" do
      expect(presenter.note).to eq("foo")
    end
  end

  describe "#contact_options" do
    it "returns a formatted hash for the log contact form" do
      expect(presenter.contact_options).to match_array([
        have_attributes(id: "phone_call", label: "Phone call"),
        have_attributes(id: "email_from_school", label: "Email from school"),
        have_attributes(id: "email_to_school", label: "Email to school"),
      ])
    end
  end
end
