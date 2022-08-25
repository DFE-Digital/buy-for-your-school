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
    subject(:schema) { described_class.new.call(body: "Filled in", attachments:) }

    let(:infected_file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
    let(:attachments) { [infected_file, ok_file] }
    let(:ok_file)              { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
    let(:wrong_file_type_file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/javascript-file.js"), "text/javascript") }

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

  describe "validates subject" do
    context "when it is blank" do
      subject(:schema) { described_class.new.call(body: "Filled in", subject: "") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "The subject cannot be blank"
      end
    end
  end

  describe "validates recipients" do
    context "when all recipients are blank" do
      subject(:schema) { described_class.new.call(body: "Filled in", subject: "Subject 000001", to_recipients: "", cc_recipients: "", bcc_recipients: "") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "At least one recipient must be specified"
      end
    end

    context "when recipients contain invalid emails" do
      subject(:schema) { described_class.new.call(body: "Filled in", subject: "Subject 000001", to_recipients: "[\"recipient1\"]", cc_recipients: "[\"recipient2\"]", bcc_recipients: "[\"recipient3\"]") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 3
        expect(schema.errors.messages[0].to_s).to eq "The TO recipients contain an invalid email address"
        expect(schema.errors.messages[1].to_s).to eq "The CC recipients contain an invalid email address"
        expect(schema.errors.messages[2].to_s).to eq "The BCC recipients contain an invalid email address"
      end
    end
  end

  describe "validates for presence of a case reference" do
    context "when not present in the subject or the body" do
      subject(:schema) { described_class.new.call(body: "hi", subject: "hello", case_ref: "000001") }

      it "raises a validation error" do
        expect(schema.errors.messages.size).to eq 1
        expect(schema.errors.messages[0].to_s).to eq "Either the subject or the message body must contain the case reference 000001"
      end
    end
  end
end
