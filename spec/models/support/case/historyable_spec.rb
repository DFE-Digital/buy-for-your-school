require "rails_helper"

describe Support::Case::Historyable do
  subject(:historyable) { create(:support_case) }

  let(:agent) { create(:support_agent) }

  around do |example|
    Current.set(agent:) do
      example.run
    end
  end

  describe "#add_note" do
    it "logs note in case history" do
      expect { historyable.add_note("My Note") }.to \
        change { Support::Interaction.note.where(agent:, case: historyable, body: "My Note").count }
        .from(0).to(1)
    end
  end

  describe "case callbacks" do
    context "when changing support_level" do
      it "logs change in case history" do
        expect { historyable.update!(support_level: "L5") }.to \
          change { Support::Interaction.case_level_changed.where(agent:, case: historyable, body: "Support level change").count }
          .from(0).to(1)
      end
    end

    context "when changing procurement stage" do
      before { define_basic_procurement_stages }

      it "logs change in case history" do
        expect { historyable.update!(procurement_stage: tender_prep_stage) }.to \
          change { Support::Interaction.case_procurement_stage_changed.where(agent:, case: historyable, body: "Procurement stage change").count }
          .from(0).to(1)
      end
    end
  end
end
