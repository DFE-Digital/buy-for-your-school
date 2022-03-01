require "rails_helper"

describe Support::IncomingEmails::CaseAssignment do
  describe ".detect_and_assign_case" do
    let(:email) { create(:support_email, sender: { "address" => "contact@email.com", "name" => "Jane Doe" }, subject: "Re: #{support_case.ref}") }
    let(:support_case) { create(:support_case) }

    it "assigns a case to the email determined by the email itself" do
      described_class.detect_and_assign_case(email)
      expect(email.case).to eq(support_case)
    end

    context "when the case has been closed" do
      let(:support_case) { create(:support_case, state: "closed") }

      it "creates a new case for the email" do
        described_class.detect_and_assign_case(email)
        expect(email.case).not_to eq(support_case)
      end
    end
  end

  describe "#case_reference_from_subject" do
    subject(:case_reference) { described_class.new(email: email).case_reference_from_subject }

    context "when subject line has 6 digit case reference in it" do
      let(:email) { double(subject: "Case 012345 - More Details") }

      it "returns the case reference" do
        expect(case_reference).to eq("012345")
      end
    end

    context "when subject line is a reply but 6 digit case reference in it" do
      let(:email) { double(subject: "Re: Case 012345 - More Details") }

      it "returns the case reference" do
        expect(case_reference).to eq("012345")
      end
    end

    context "when subject line contains no decernable case reference" do
      let(:email) { double(subject: "Case Closed") }

      it "returns nil" do
        expect(case_reference).to be_nil
      end
    end

    describe "subject lines to match" do
      [
        "Case 000123 - Enquiry",
        "FW: Case 000123 - Enquiry",
        "RE: Case 000123 - Enquiry",
        "RE: 000123 - Enquiry",
        "Re: 000123 Enquiry",
        "Re: Case 000123 Enquiry",
      ].each do |subject|
        it { expect(described_class.new(email: double(subject: subject)).case_reference_from_subject).to eq("000123") }
      end
    end

    describe "subject lines to ignore" do
      [
        "Aldgate 120777",
        "Another URN 10233435",
      ].each do |subject|
        it { expect(described_class.new(email: double(subject: subject)).case_reference_from_subject).to be_nil }
      end
    end
  end

  describe "#case_reference_from_body" do
    subject(:case_reference) { described_class.new(email: email).case_reference_from_body }

    context "when email body has the 6 digit case reference in it" do
      let(:email) { double(body: "Hello X,\n\nPlease read the following...\n\nYour reference number is: 098765\. Please quote this number when you speak to our team.\n\nKind Regards\nJuly Bloggs") }

      it "returns the case reference" do
        expect(case_reference).to eq("098765")
      end
    end

    context "when email body contains no decernable case reference" do
      let(:email) { double(body: "Hello X,\n\nPlease read the following...\n\nKind Regards\nJuly Bloggs") }

      it "returns nil" do
        expect(case_reference).to be_nil
      end
    end
  end

  describe "#case_reference_from_conversation" do
    subject(:case_reference) { described_class.new(email: email).case_reference_from_conversation }

    context "when email has a conversation id" do
      let(:email) { double(outlook_conversation_id: "OLCID1") }

      context "when emails exist in the same thread attached to a case" do
        before do
          create(:support_email, outlook_conversation_id: "OLCID1", case: create(:support_case, ref: "123456")) # this one is picked
          create(:support_email, outlook_conversation_id: "OLCID1", case: nil)
          create(:support_email, outlook_conversation_id: "OLCID1", case: nil)
          create(:support_email, outlook_conversation_id: "OLCID1", case: create(:support_case, ref: "234567")) # different ref to demonstrate sort
          create(:support_email, outlook_conversation_id: "OLCID2", case: create(:support_case, ref: "123457")) # different ocid to demo filtering
        end

        it "returns the case reference from another email in the thread" do
          expect(case_reference).to eq("123456")
        end
      end
    end
  end

  describe "#case_for_email" do
    subject(:case_for_email) { case_assignment.case_for_email }

    let(:email_folder) { :inbox }
    let(:email_sender) { { "address" => "contact@email.com", "name" => "Contact Multi Part Name" } }
    let(:email) { double(sender: email_sender, sent_items?: email_folder == :sent_items) }
    let(:case_assignment) { described_class.new(email: email) }
    let(:subject_ref) { "100000" }
    let(:body_ref) { "200000" }
    let(:conversation_ref) { "300000" }

    before do
      allow(case_assignment).to receive(:case_reference_from_subject).and_return(subject_ref)
      allow(case_assignment).to receive(:case_reference_from_body).and_return(body_ref)
      allow(case_assignment).to receive(:case_reference_from_conversation).and_return(conversation_ref)

      create(:support_case, ref: "100000")
      create(:support_case, ref: "200000")
      create(:support_case, ref: "300000")
    end

    context "when a case reference can be determined from the email subject" do
      it "returns the case with that reference" do
        expect(case_for_email.ref).to eq("100000")
      end

      context "when there is no case in the system for that ref" do
        let(:subject_ref) { "ABCDEF" }

        it "creates a new case for the email to be assigned to" do
          expect(case_for_email.ref).to eq(Support::Case.last.ref)
          expect(case_for_email.source).to eq("incoming_email")
          expect(case_for_email.email).to eq("contact@email.com")
          expect(case_for_email.first_name).to eq("Contact")
          expect(case_for_email.last_name).to eq("Multi Part Name")
          expect(case_for_email.action_required).to be(true)
        end
      end
    end

    context "when a case reference cannot be determined by the subject" do
      let(:subject_ref) { nil }

      context "when a case reference can be determined from the email body" do
        it "returns the case with that reference" do
          expect(case_for_email.ref).to eq("200000")
        end
      end

      context "when a case reference can be determined from the conversation" do
        let(:body_ref) { nil }

        it "returns the case with that reference" do
          expect(case_for_email.ref).to eq("300000")
        end
      end

      context "when all else fails" do
        let(:body_ref) { nil }
        let(:conversation_ref) { nil }

        context "when the email is in the sent_items folder" do
          let(:email_folder) { :sent_items }

          it "no further cases are created and none assigned to the email" do
            expect(case_for_email).to be_nil
            expect(Support::Case.count).to eq(3) # 3 created in the "before" above
          end
        end

        context "when the email is in the inbox folder" do
          let(:email_folder) { :inbox }

          it "creates a new case for the email to be assigned to" do
            expect(case_for_email.ref).to eq(Support::Case.last.ref)
            expect(case_for_email.source).to eq("incoming_email")
            expect(case_for_email.email).to eq("contact@email.com")
            expect(case_for_email.first_name).to eq("Contact")
            expect(case_for_email.last_name).to eq("Multi Part Name")
            expect(case_for_email.action_required).to be(true)
          end

          context "when the sender only has one name" do
            let(:email_sender) { { "address" => "contact@email.com", "name" => "Contact" } }

            it "sets the contact details as XXX" do
              expect(case_for_email.ref).to eq(Support::Case.last.ref)
              expect(case_for_email.source).to eq("incoming_email")
              expect(case_for_email.email).to eq("contact@email.com")
              expect(case_for_email.first_name).to eq("Contact")
              expect(case_for_email.last_name).to eq("")
              expect(case_for_email.action_required).to be(true)
            end
          end
        end
      end
    end
  end
end
