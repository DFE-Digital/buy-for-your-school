describe Support::MessagePresenter do
  subject(:presenter) { described_class.new(message_interaction) }

  describe "#self.presenter_for" do
    context("when the message interaction has an email") do
      let(:email) { create(:support_email) }
      let(:message_interaction) { create(:support_interaction, :email_from_school, additional_data: { email_id: email.id }) }

      it "returns OutlookMessagePresenter" do
        expect(described_class.presenter_for(message_interaction)).to be_a Support::Messages::OutlookMessagePresenter
      end
    end

    context("when the message interaction has no email") do
      let(:message_interaction) { create(:support_interaction, :email_from_school) }

      it "returns NotifyMessagePresenter" do
        expect(described_class.presenter_for(message_interaction)).to be_a Support::Messages::NotifyMessagePresenter
      end
    end
  end
end
