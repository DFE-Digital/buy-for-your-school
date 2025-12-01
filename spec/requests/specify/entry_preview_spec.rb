# TODO: this should be merged with features/design/preview_step_spec
RSpec.describe "Entry previews", type: :request do
  let(:user) { create(:user) }
  let(:journey) { user.journeys.first }
  let(:step) { journey.steps.first }

  before do
    user_is_signed_in(user:)

    stub_contentful_entry(
      entry_id: "short-text-question",
      fixture_filename: "steps/short-text-question.json",
    )

    get "/preview/entries/short-text-question"
  end

  it "builds a disposable associations for the step" do
    expect(user.journeys.count).to eq 1
    expect(journey.sections.count).to eq 1
    expect(journey.tasks.count).to eq 1
    expect(journey.steps.count).to eq 1
  end

  it "marks the journey for deletion hiding it from the dashboard" do
    expect(journey.state).to eq "remove"
  end

  it "redirects to the step page" do
    expect(response).to have_http_status :found
    expect(response).to redirect_to "/journeys/#{journey.id}/steps/#{step.id}?preview=true"
  end

  context "when multiple previews are made" do
    before do
      stub_contentful_entry(
        entry_id: "currency-question",
        fixture_filename: "steps/currency-question.json",
      )

      get "/preview/entries/currency-question"
    end

    it "reuses the journey for all previewed steps" do
      expect(user.journeys.count).to eq 1
      expect(journey.sections.count).to eq 1
      expect(journey.tasks.count).to eq 1
      expect(journey.steps.count).to eq 2
    end
  end
end
