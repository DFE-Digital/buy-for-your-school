require "rails_helper"

describe Support::SaveAttachmentsFormRow do
  describe "validation" do
    context "when a description is missing" do
      specify "is invalid" do
        subject = described_class.new(description: nil)
        subject.valid?
        expect(subject.errors.messages.to_h).to include(description: ["Enter a description"])
      end
    end

    context "when the name has already been taken for this case" do
      specify "is invalid" do
        support_case = create(:support_case)
        create(:support_case_attachment, case: support_case, name: "ExistingFile.pdf")

        subject = described_class.new(name: "ExistingFile.pdf", support_case_id: support_case.id)
        subject.valid?
        expect(subject.errors.messages.to_h).to include(name: ["Enter new attachment name"])
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
          expect(subject.errors.messages.to_h).to include(name: ["Enter new attachment name"])
        end
      end
    end
  end
end
