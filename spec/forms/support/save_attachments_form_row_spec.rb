require "rails_helper"

describe Support::SaveAttachmentsFormRow do
  describe "#file_name_to_save" do
    context "when file type is specified already" do
      it "does not duplicate it" do
        attachment = create(:support_email_attachment).tap { |a| a.update(file_name: "test.pdf") }
        subject = described_class.new(email_attachment: attachment, name: "MyFileName.pdf")
        expect(subject.file_name_to_save).to eq("MyFileName.pdf")
      end
    end

    context "when no file type is specified" do
      it "is taken from the attchment" do
        attachment = create(:support_email_attachment).tap { |a| a.update(file_name: "test.pdf") }
        subject = described_class.new(email_attachment: attachment, name: "MyFileNameWithoutExtension")
        expect(subject.file_name_to_save).to eq("MyFileNameWithoutExtension.pdf")
      end
    end
  end

  describe "validation" do
    let(:attachment) { create(:support_email_attachment) }

    context "when a description is missing" do
      specify "is invalid" do
        subject = described_class.new(description: nil, email_attachment: attachment)
        subject.valid?
        expect(subject.errors.messages.to_h).to include(description: ["Enter a description"])
      end
    end

    context "when the name has already been taken for this case" do
      specify "is invalid" do
        support_case = create(:support_case)
        create(:support_case_attachment, case: support_case, name: "ExistingFile.txt")

        subject = described_class.new(name: "ExistingFile.txt", support_case_id: support_case.id, email_attachment: attachment)
        subject.valid?
        expect(subject.errors.messages.to_h).to include(name: ["File already exists. Enter new attachment name"])
      end
    end

    context "when name is not specified" do
      context "but email attachment has a name that already exists as CaseAttachment" do
        specify "is invalid as the fallback name is still a duplicate" do
          support_case = create(:support_case)
          email_attachment = create(:support_email_attachment)
          create(:support_case_attachment, case: support_case, name: "attachment.txt")

          subject = described_class.new(name: nil, support_case_id: support_case.id, support_email_attachment_id: email_attachment.id)
          subject.valid?
          expect(subject.errors.messages.to_h).to include(name: ["File already exists. Enter new attachment name"])
        end
      end
    end
  end
end
