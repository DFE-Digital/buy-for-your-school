require "rails_helper"

describe Support::SaveAttachmentsForm do
  let(:case_1) { create(:support_case) }
  let(:case_2) { create(:support_case) }
  let(:email_attachment_1) { create(:support_email_attachment) }
  let(:email_attachment_2) { create(:support_email_attachment) }

  describe "#save_attachments" do
    before { described_class.new(**input).save_attachments }

    context "when multiple attachments are given" do
      let(:input) do
        {
          attachments_attributes: {
            0 => {
              support_case_id: case_1.id,
              support_email_attachment_id: email_attachment_1.id,
              name: "Case1EmailAttachment1.pdf",
              description: "A really nice file...",
              selected: "1",
            },
            1 => {
              support_case_id: case_2.id,
              support_email_attachment_id: email_attachment_2.id,
              name: "Case2EmailAttachment2.pdf",
              description: "A really pleasent file...",
              selected: "1",
            },
          },
        }
      end

      it "saves each of the attachments to the case" do
        attachment_1 = Support::CaseAttachment.find_by(name: "Case1EmailAttachment1.pdf")
        expect(attachment_1.case).to eq(case_1)
        expect(attachment_1.email_attachment).to eq(email_attachment_1)
        expect(attachment_1.description).to eq("A really nice file...")

        attachment_2 = Support::CaseAttachment.find_by(name: "Case2EmailAttachment2.pdf")
        expect(attachment_2.case).to eq(case_2)
        expect(attachment_2.email_attachment).to eq(email_attachment_2)
        expect(attachment_2.description).to eq("A really pleasent file...")
      end

      context "but a row is not selected" do
        let(:input) do
          {
            attachments_attributes: {
              0 => {
                support_case_id: case_1.id,
                support_email_attachment_id: email_attachment_1.id,
                name: "Case1EmailAttachment1.pdf",
                description: "A really nice file...",
                selected: "0",
              },
            },
          }
        end

        specify "that row is not saved" do
          expect(Support::CaseAttachment.count).to eq(0)
        end
      end
    end

    context "when attachment name is empty" do
      let(:input) do
        {
          attachments_attributes: {
            0 => {
              support_case_id: case_1.id,
              support_email_attachment_id: email_attachment_1.id,
              name: nil,
              description: "A really nice file...",
              selected: "1",
            },
          },
        }
      end

      it "uses the email attachment name as the name" do
        attachment = Support::CaseAttachment.find_by(case: case_1, email_attachment: email_attachment_1)
        expect(attachment.name).to eq(email_attachment_1.file_name)
      end
    end
  end
end
