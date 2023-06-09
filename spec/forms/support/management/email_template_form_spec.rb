require "rails_helper"

describe Support::Management::EmailTemplateForm, type: :model do
  subject(:form) { described_class.new(**params) }

  let(:params) { {} }

  describe "validation" do
    describe "group_id" do
      it { is_expected.to validate_presence_of(:group_id) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:group_id]).to eq ["Select a template group"]
        end
      end
    end

    describe "title" do
      it { is_expected.to validate_presence_of(:title) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:title]).to eq ["Enter a template name"]
        end
      end
    end

    describe "description" do
      it { is_expected.to validate_presence_of(:description) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:description]).to eq ["Enter template guidance"]
        end
      end
    end

    describe "body" do
      it { is_expected.to validate_presence_of(:body) }

      context "when validation fails" do
        it "gives an error message" do
          expect(form).not_to be_valid
          expect(form.errors.messages[:body]).to eq ["Enter a template body"]
        end
      end
    end
  end

  describe ".from_email_template" do
    let(:created_by) { create(:support_agent) }
    let(:updated_by) { create(:support_agent) }
    let(:group) { create(:support_email_template_group, parent: nil) }
    let(:email_template) { create(:support_email_template, group:, created_by:, updated_by:) }

    it "returns a new form with given template's attributes" do
      new_form = described_class.from_email_template(email_template.id)
      expect(new_form.id).to eq(email_template.id)
      expect(new_form.group_id).to eq(group.id)
      expect(new_form.subgroup_id).to be_nil
      expect(new_form.stage).to eq(email_template.stage)
      expect(new_form.title).to eq(email_template.title)
      expect(new_form.description).to eq(email_template.description)
      expect(new_form.subject).to eq(email_template.subject)
      expect(new_form.body).to eq(email_template.body)
      expect(new_form.created_by).to eq(email_template.created_by)
      expect(new_form.updated_by).to eq(email_template.updated_by)
    end

    context "when the template group is a subgroup" do
      let(:subgroup) { create(:support_email_template_group, parent: group) }
      let(:email_template) { create(:support_email_template, group: subgroup) }

      it "correctly assigns the group and subgroup IDs" do
        new_form = described_class.from_email_template(email_template.id)
        expect(new_form.id).to eq(email_template.id)
        expect(new_form.group_id).to eq(group.id)
        expect(new_form.subgroup_id).to eq(subgroup.id)
      end
    end
  end

  describe "#save!" do
    let(:agent) { create(:support_agent) }
    let(:group) { create(:support_email_template_group, parent: nil) }

    context "when saving a new template" do
      let(:attachments) { [fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain")] }
      let(:params) do
        { group_id: group.id, stage: 2, title: "New template", description: "New template description", subject: "New subject", body: "New body", agent:, attachments: }
      end

      it "persists all given attributes" do
        form.save!
        saved_template = Support::EmailTemplate.first
        expect(saved_template.group).to eq(group)
        expect(saved_template.stage).to eq(2)
        expect(saved_template.title).to eq("New template")
        expect(saved_template.description).to eq("New template description")
        expect(saved_template.subject).to eq("New subject")
        expect(saved_template.body).to eq("New body")
        expect(saved_template.created_by).to eq(agent)
        expect(saved_template.updated_by).to eq(agent)
        expect(saved_template.attachments.size).to eq(1)
        expect(saved_template.attachments.first.file_name).to eq("text-file.txt")
      end
    end

    context "when updating an existing template" do
      let(:old_agent) { create(:support_agent) }
      let(:new_agent) { create(:support_agent) }
      let(:subgroup) { create(:support_email_template_group, parent: group) }
      let(:attachments) { [fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain")] }
      let!(:email_template) { create(:support_email_template, group:, title: "Old template", created_by: old_agent, updated_by: old_agent, attachments: [create(:support_email_template_attachment)]) }
      let(:params) do
        { id: email_template.id, group_id: group.id, subgroup_id: subgroup.id, stage: 4, title: "New template", description: "New template description", body: "New body", agent: new_agent, attachments: }
      end

      it "updates all given attributes" do
        expect { form.save! }
        .to(
          change { email_template.reload.group }.from(group).to(subgroup)
          .and(change { email_template.reload.stage }.from(0).to(4))
          .and(change { email_template.reload.title }.from("Old template").to("New template"))
          .and(change { email_template.reload.description }.from("This is a test email template").to("New template description"))
          .and(change { email_template.reload.body }.from("Test email template body").to("New body"))
          .and(change { email_template.reload.updated_by }.from(old_agent).to(new_agent))
          .and(change { email_template.reload.attachments.size }.from(1).to(2))
          .and(not_change { email_template.reload.created_by }),
        )
      end
    end

    context "when there are attachments to remove" do
      let!(:email_template) { create(:support_email_template, group:, title: "Test template", created_by: agent, updated_by: agent) }
      let!(:attachment_1) { create(:support_email_template_attachment, template: email_template) }
      let!(:attachment_2) { create(:support_email_template_attachment, template: email_template) }
      let(:params) { { id: email_template.id, group_id: group.id, remove_attachments: [attachment_1.id, attachment_2.id].to_json, agent: } }

      it "removes given attachments" do
        expect { form.save! }.to change(Support::EmailTemplateAttachment, :count).by(-2)
      end
    end
  end

  describe "#group_options" do
    let!(:group_a) { create(:support_email_template_group, title: "Group A") }
    let!(:group_b) { create(:support_email_template_group, title: "Group B", parent: group_a) }
    let!(:group_c) { create(:support_email_template_group, title: "Group C") }

    it "returns all top-level groups as arrays of titles and IDs" do
      groups = form.group_options
      expect(groups).to include([group_a.title, group_a.id], [group_c.title, group_c.id])
      expect(groups).not_to include([group_b.title, group_b.id])
    end
  end

  describe "#subgroup_options" do
    context "when a group is not provided" do
      it "returns an empty array" do
        expect(form.subgroup_options).to be_empty
      end
    end

    context "when a group is provided" do
      let(:group) { create(:support_email_template_group, title: "Group") }
      let!(:subgroup_1) { create(:support_email_template_group, title: "Subgroup 1", parent: group) }
      let!(:subgroup_2) { create(:support_email_template_group, title: "Subgroup 2", parent: group) }
      let(:params) { { group_id: group.id } }

      it "returns all its subgroups as arrays of titles and IDs" do
        expect(form.subgroup_options).to include([subgroup_1.title, subgroup_1.id], [subgroup_2.title, subgroup_2.id])
      end
    end
  end

  describe "#stage_options" do
    it "returns all stages" do
      expect(form.stage_options).to include(
        ["Stage 0", 0],
        ["Stage 1", 1],
        ["Stage 2", 2],
        ["Stage 3", 3],
        ["Stage 4", 4],
      )
    end
  end

  describe "#email_template" do
    context "when an ID is provided" do
      let(:email_template) { create(:support_email_template) }
      let(:params) { { id: email_template.id } }

      it "returns the email template" do
        expect(form.email_template).to eq(email_template)
      end
    end

    context "when no ID is provided" do
      it "returns a new email template" do
        expect(form.email_template.id).to be_nil
      end
    end
  end

  describe "#files_safe" do
    let(:text_file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/text-file.txt"), "text/plain") }
    let(:js_file) { fixture_file_upload(Rails.root.join("spec/fixtures/support/javascript-file.js"), "text/javascript") }

    context "when there are no attachments" do
      let(:params) { { attachments: [] } }

      before { form.files_safe }

      it "does not create a validation error" do
        expect(form.errors.messages[:attachments]).to be_empty
      end
    end

    context "when the attachments do not contain infected files" do
      let(:params) { { attachments: [text_file, js_file] } }

      before do
        allow(Support::VirusScanner).to receive(:uploaded_file_safe?).and_return(true)

        form.files_safe
      end

      it "does not create a validation error" do
        expect(form.errors.messages[:attachments]).to be_empty
      end
    end

    context "when the attachments contain infected files" do
      let(:params) { { attachments: [text_file, js_file] } }

      before do
        allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(text_file).and_return(true)
        allow(Support::VirusScanner).to receive(:uploaded_file_safe?).with(js_file).and_return(false)

        form.files_safe
      end

      it "creates a validation error" do
        expect(form.errors.messages[:attachments]).to eq ["One or more attachments contain a virus"]
      end
    end
  end
end
