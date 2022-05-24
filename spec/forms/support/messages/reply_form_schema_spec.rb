RSpec.describe Support::Messages::ReplyFormSchema do
  describe "validates body" do
    context "when it is blank" do
      subject(:schema) { described_class.new.call(body: "") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "The reply body cannot be blank"
      end
    end
  end

  context "when files have been attached" do

    let(:infected_file)        { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
    let(:ok_file)              { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
    let(:wrong_file_type_file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/javascript-file.js"), "text/javascript") }


    subject(:schema) { described_class.new.call(body: "Filled in", attachments: attachments) }
    let(:attachments) { [infected_file, ok_file] }

    context "when a file is infected with a virus" do
      before { allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(infected_file).and_return(false) }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "One or more of the files you uploaded contained a virus and have been rejected"
      end
    end

    context "when a file format is not allowed" do
      let(:attachments) { [ok_file, wrong_file_type_file] }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "One or more of the files you uploaded was an incorrect file type"
      end
    end
  end
end
