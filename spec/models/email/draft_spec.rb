require "rails_helper"

describe Email::Draft do
  let(:draft) { described_class.new(email:) }

  let(:email) { double(Email) }

  describe "Validation" do
    describe "Attachment sizes" do
      context "when the total attachment size is greater than 35 MB" do
        before do
          allow(email).to receive(:attachments).and_return([1])
          allow(email).to receive(:total_attachment_size).and_return(35_000_001)
        end

        it "fails validation" do
          expect(draft).not_to be_valid
          expect(draft.errors.messages[:base]).to eq ["The total attachment size cannot exceed 35 MB. Please reduce the size of your attachments."]
        end
      end
    end
  end
end
