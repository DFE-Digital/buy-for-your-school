# spec/support/shared_contexts/email_reply.rb
RSpec.shared_context "with a support case and email" do
  let(:support_case) { create(:support_case) }
  let(:email)        { create(:support_email, origin, ticket: support_case) }
  let(:origin)       { :inbox }
  let(:interaction_type) { :email_from_school }
  let(:additional_data)  { { email_id: email.id } }

  before do
    create(:support_interaction, interaction_type,
           body: email.body,
           additional_data:,
           case: support_case)

    visit support_case_path(support_case)
  end
end

RSpec.shared_context "with navigated to messages view" do |frame: "#messages-frame", link: "View"|
  before do
    click_link "Messages"
    within(frame) { click_link link }
  end
end
