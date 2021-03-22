require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "Endpoints that don't require authentication" do
    it "the health_check endpoint is not authenticated" do
      get health_check_path
      expect(response).to have_http_status(:ok)
    end

    it "users can access the specification start page" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "users can access the planning guidance page" do
      get planning_path
      expect(response).to have_http_status(:ok)
    end

    it "users can access the new session endpoint" do
      get new_dfe_path
      expect(response).to have_http_status(:found)
    end

    it "DfE Sign-in can redirect users back to the service with the callback endpoint" do
      get auth_dfe_callback_path
      expect(response).to have_http_status(:found)
    end

    it "DfE Sign-in can sign users out" do
      get auth_dfe_signout_path
      expect(response).to have_http_status(:found)
    end
  end

  describe "Endpoints that do require authentication" do
    it "users cannot access the new journey path" do
      get new_journey_path
      expect(response).to redirect_to(new_dfe_path)
    end

    it "users cannot access an existing journey" do
      journey = create(:journey)
      get journey_path(journey)
      expect(response).to redirect_to(new_dfe_path)
    end

    it "users cannot edit an answer" do
      answer = create(:radio_answer)
      get edit_journey_step_path(answer.step.journey, answer.step)
      expect(response).to redirect_to(new_dfe_path)
    end

    it "users cannot see the journey map" do
      get new_journey_map_path
      expect(response).to redirect_to(new_dfe_path)
    end

    it "users cannot see the preview endpoints" do
      get preview_entry_path("an-entry-id")
      expect(response).to redirect_to(new_dfe_path)
    end
  end
end
