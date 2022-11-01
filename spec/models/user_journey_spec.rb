describe UserJourney, type: :model do
  describe ".find_or_create_new_in_progress_by" do
    let!(:existing_user_journey) { create(:user_journey, session_id: "SESSION_ID") }

    context "when record exists for given criteria" do
      it "does not create another" do
        described_class.find_or_create_new_in_progress_by(session_id: "SESSION_ID")
        expect(described_class.count).to eq(1)
      end

      it "returns the existing record" do
        expect(described_class.find_or_create_new_in_progress_by(session_id: "SESSION_ID")).to eq(existing_user_journey)
      end
    end

    context "when record does not exist for given criteria" do
      it "creates a new user journey in in_progress status" do
        new_record = described_class.find_or_create_new_in_progress_by(session_id: "NEW_SESSION_ID")
        expect(described_class.count).to eq(2)
        expect(new_record).to be_in_progress
      end

      it "does not try to change the id of the new record" do
        new_record = described_class.find_or_create_new_in_progress_by(id: "NOT_AN_ID")
        expect(new_record.id).not_to eq("NOT_AN_ID")
      end
    end
  end

  describe "#record_step" do
    it "saves a new user_journey_step with the given values" do
      user_journey = create(:user_journey)
      user_journey.record_step(product_section: :ghbs_rfh, step_description: "/step-desc")
      user_journey_step = user_journey.reload.user_journey_steps.last
      expect(user_journey_step.product_section).to eq("ghbs_rfh")
      expect(user_journey_step.step_description).to eq("/step-desc")
    end
  end
end
