require "rails_helper"

describe Support::Case::QuickEditable do
  subject(:quick_editable) { create(:support_case) }

  let(:agent) { create(:support_agent) }

  before { Current.agent = agent }

  describe "#quick_edit" do
    it "updates the case with the given details" do
      expect { quick_editable.quick_edit(note: "ignored", email: "new@email.com") }.to \
        change { quick_editable.reload.email }.to("new@email.com")
    end

    it "creates a new case note with the given note details" do
      expect { quick_editable.quick_edit(note: "not ignored", email: "new@email.com") }.to \
        change { quick_editable.reload.interactions.note.where(body: "not ignored").count }
        .from(0).to(1)
    end

    context "when there is a failure" do
      before do
        quick_editable.class_eval do
          def save!(*)
            raise "Simulated failure!"
          end
        end
      end

      it "does not save anything" do
        expect { quick_editable.quick_edit(note: "not ignored", email: "new@email.com") }.to \
          not_change { Support::Interaction.count }.and \
            not_change { quick_editable.reload.email }.and \
              raise_error(StandardError)
      end
    end

    context "when the case note has not changed" do
      before { quick_editable.interactions.note.create!(body: "existing note") }

      it "does not create it" do
        expect { quick_editable.quick_edit(note: "existing note") }.to \
          (not_change { quick_editable.reload.interactions.note.where(body: "existing note").count })
      end
    end
  end

  context "when the case note has not changed" do
    before { quick_editable.interactions.note.create!(body: "existing note") }

    it "does not create it" do
      expect { quick_editable.quick_edit(note: "existing note") }.to \
        (not_change { quick_editable.reload.interactions.note.where(body: "existing note").count })
    end
  end
end
