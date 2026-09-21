require "rails_helper"

RSpec.describe PageFeedbacksController, type: :controller do
  let(:page_url) { "https://example.com/some-page" }
  let(:feedback) { "This page was helpful." }

  describe "GET #widget" do
    it "renders successfully" do
      get :widget, params: { page_url: }
      expect(response).to be_successful
    end
  end

  describe "GET #ask_feedback" do
    it "renders successfully" do
      # get :ask_feedback, params: { page_url:, page_useful: "true" }
      get :ask_feedback, params: { page_url: }
      expect(response).to be_successful
    end
  end

  describe "GET #form" do
    it "renders successfully" do
      get :form, params: { page_url:, page_useful: "true", wants_feedback: "true" }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        page_feedback: {
          page_url:,
          page_useful: "true",
          wants_feedback: "false",
          feedback:,
        },
      }
    end

    context "with valid params" do
      it "saves a new PageFeedback" do
        expect {
          post :create, params: valid_params
        }.to change(PageFeedback, :count).by(1)

        page_feedback = PageFeedback.last

        expect(page_feedback.page_url).to eq(page_url)
        expect(page_feedback.page_useful).to eq(true)
        expect(page_feedback.wants_feedback).to eq(false)
        expect(page_feedback.feedback).to eq(feedback)
      end

      it "renders the :thanks template" do
        post :create, params: valid_params
        expect(response).to render_template(:thanks)
      end
    end
  end
end
